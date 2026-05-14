#!/usr/bin/env python3
"""
Upload an App Store Connect Product Page Optimization (PPO) experiment with
the 3 marketing treatments rendered by the per-app screenshots tool.

What this does:
  • Authenticates with the ASC API using the App Store Connect API key.
  • Locates the live (READY_FOR_SALE) version of the app identified by
    APP_BUNDLE_ID.
  • Creates a new PPO Experiment (V2) attached to that live version.
  • Creates 3 treatments inside the experiment (A / B / C).
  • For each (treatment × locale × screenshot), finds-or-creates the
    screenshot set on the treatment localization, clears any inherited
    cloned screenshots, then uploads the PNG via the 3-step upload protocol
    (POST → PUT bytes → PATCH uploaded:true).

Why this exists:
  fastlane deliver only writes to the DEFAULT product page. PPO experiments
  live on a separate API surface (`appStoreVersionExperimentsV2`), so we
  call the API directly. The live default product page is NEVER touched.

Requirements:
  pip install pyjwt cryptography requests

Required env vars:
  APP_STORE_CONNECT_KEY_ID
  APP_STORE_CONNECT_ISSUER_ID
  APP_STORE_CONNECT_KEY_PATH    (path to .p8 file)
  APP_BUNDLE_ID                 (e.g. com.gambitstudio.yourapp)

Optional env vars:
  APP_DISPLAY_NAME              (defaults to "Headlines A/B")
  APP_LOCALES                   (comma-separated, defaults to en-US,pt-BR,es-ES,es-MX)
  APP_DISPLAY_TYPE              (defaults to APP_IPHONE_69 — set to match the
                                 live default product page's display type)

Usage:
  APP_BUNDLE_ID="com.gambitstudio.yourapp" python3 upload_ppo.py
"""

from __future__ import annotations

import hashlib
import json
import os
import sys
import time
from datetime import datetime
from pathlib import Path
from typing import Any, Optional

import jwt
import requests

# MARK: - ASC API auth (required env vars — no defaults; fail loud if missing)

def _required_env(name: str) -> str:
    value = os.getenv(name)
    if not value:
        sys.exit(f"error: env var {name} is required (set it before running this script)")
    return value

KEY_ID = _required_env("APP_STORE_CONNECT_KEY_ID")
ISSUER_ID = _required_env("APP_STORE_CONNECT_ISSUER_ID")
KEY_PATH = os.path.expanduser(_required_env("APP_STORE_CONNECT_KEY_PATH"))

# MARK: - Per-app config (override via env vars)

BUNDLE_ID = _required_env("APP_BUNDLE_ID")
DISPLAY_NAME = os.getenv("APP_DISPLAY_NAME", "Headlines A/B")
EXPERIMENT_NAME = f"{DISPLAY_NAME} {datetime.now().strftime('%Y-%m-%d')}"

TREATMENTS = [
    ("A", "Direct / Action"),
    ("B", "Emotional / Aspirational"),
    ("C", "Feature / Technical"),
]
LOCALES = os.getenv("APP_LOCALES", "en-US,pt-BR,es-ES,es-MX").split(",")

# Must match the existing default product page display type — query
# /v1/appStoreVersions/{id}/appStoreVersionLocalizations/{loc}/appScreenshotSets
# on the live version to find the right value. Common: APP_IPHONE_65 (1242×2688),
# APP_IPHONE_67 (1284×2778), APP_IPHONE_69 (1320×2868).
DISPLAY_TYPE = os.getenv("APP_DISPLAY_TYPE", "APP_IPHONE_69")

SCREENSHOTS_BASE = Path(__file__).resolve().parent / "screenshots"
BASE = "https://api.appstoreconnect.apple.com"


# MARK: - Auth

def make_token() -> str:
    private_key = Path(KEY_PATH).read_text()
    now = int(time.time())
    return jwt.encode(
        {
            "iss": ISSUER_ID,
            "iat": now,
            "exp": now + 1200,
            "aud": "appstoreconnect-v1",
        },
        private_key,
        algorithm="ES256",
        headers={"kid": KEY_ID, "typ": "JWT"},
    )


# MARK: - HTTP helpers

class APIError(Exception):
    pass


def _check(r: requests.Response, where: str) -> Any:
    if not r.ok:
        try:
            detail = json.dumps(r.json(), indent=2)
        except Exception:
            detail = r.text
        raise APIError(f"{where} → {r.status_code}\n{detail}")
    if r.status_code == 204 or not r.content:
        return None
    return r.json()


def get(headers: dict, path: str, params: Optional[dict] = None) -> Any:
    return _check(requests.get(f"{BASE}{path}", headers=headers, params=params), f"GET {path}")


def post(headers: dict, path: str, body: dict) -> Any:
    return _check(
        requests.post(
            f"{BASE}{path}",
            headers={**headers, "Content-Type": "application/json"},
            json=body,
        ),
        f"POST {path}",
    )


def patch(headers: dict, path: str, body: dict) -> Any:
    return _check(
        requests.patch(
            f"{BASE}{path}",
            headers={**headers, "Content-Type": "application/json"},
            json=body,
        ),
        f"PATCH {path}",
    )


def delete(headers: dict, path: str) -> Any:
    return _check(requests.delete(f"{BASE}{path}", headers=headers), f"DELETE {path}")


# MARK: - Lookups

def find_app(headers: dict) -> dict:
    data = get(headers, "/v1/apps", {"filter[bundleId]": BUNDLE_ID})
    apps = data.get("data", [])
    if not apps:
        raise APIError(f"App with bundleId={BUNDLE_ID} not found.")
    return apps[0]


def find_live_version(headers: dict, app_id: str) -> dict:
    data = get(
        headers,
        f"/v1/apps/{app_id}/appStoreVersions",
        {"filter[appStoreState]": "READY_FOR_SALE", "limit": 1},
    )
    versions = data.get("data", [])
    if not versions:
        raise APIError(
            "No live (READY_FOR_SALE) version found. PPO experiments require a "
            "shipping version to test against."
        )
    return versions[0]


def list_existing_experiments(headers: dict, app_id: str) -> list[dict]:
    data = get(
        headers,
        f"/v1/apps/{app_id}/appStoreVersionExperimentsV2",
    )
    return data.get("data", [])


# MARK: - PPO creation

def create_experiment(headers: dict, app_id: str, name: str) -> dict:
    # V2 attaches the experiment to the APP (with a platform attribute) rather
    # than to a specific app store version. Apple manages the version coupling
    # internally based on the live release.
    body = {
        "data": {
            "type": "appStoreVersionExperiments",
            "attributes": {
                "name": name,
                "platform": "IOS",
                "trafficProportion": 50,  # 50% test traffic, split between treatments
            },
            "relationships": {
                "app": {
                    "data": {"type": "apps", "id": app_id}
                }
            },
        }
    }
    return post(headers, "/v2/appStoreVersionExperiments", body)["data"]


def create_treatment(headers: dict, experiment_id: str, name: str) -> dict:
    body = {
        "data": {
            "type": "appStoreVersionExperimentTreatments",
            "attributes": {"name": name},
            "relationships": {
                "appStoreVersionExperimentV2": {
                    "data": {
                        "type": "appStoreVersionExperiments",
                        "id": experiment_id,
                    }
                }
            },
        }
    }
    return post(headers, "/v1/appStoreVersionExperimentTreatments", body)["data"]


def create_localization(headers: dict, treatment_id: str, locale: str) -> dict:
    body = {
        "data": {
            "type": "appStoreVersionExperimentTreatmentLocalizations",
            "attributes": {"locale": locale},
            "relationships": {
                "appStoreVersionExperimentTreatment": {
                    "data": {
                        "type": "appStoreVersionExperimentTreatments",
                        "id": treatment_id,
                    }
                }
            },
        }
    }
    return post(headers, "/v1/appStoreVersionExperimentTreatmentLocalizations", body)["data"]


def create_screenshot_set(headers: dict, localization_id: str, display_type: str) -> dict:
    body = {
        "data": {
            "type": "appScreenshotSets",
            "attributes": {"screenshotDisplayType": display_type},
            "relationships": {
                "appStoreVersionExperimentTreatmentLocalization": {
                    "data": {
                        "type": "appStoreVersionExperimentTreatmentLocalizations",
                        "id": localization_id,
                    }
                }
            },
        }
    }
    return post(headers, "/v1/appScreenshotSets", body)["data"]


def find_or_create_screenshot_set(headers: dict, localization_id: str, display_type: str) -> dict:
    """
    ASC clones the default product page's screenshot sets into every new
    treatment localization. POSTing a new set for an already-cloned display
    type fails with 409. So we find the existing one for our target display
    type, fall back to creating a new one only if it doesn't exist.
    """
    data = get(
        headers,
        f"/v1/appStoreVersionExperimentTreatmentLocalizations/{localization_id}/appScreenshotSets",
    )
    for s in data.get("data", []):
        if s["attributes"].get("screenshotDisplayType") == display_type:
            return s
    return create_screenshot_set(headers, localization_id, display_type)


def reset_screenshot_set(headers: dict, localization_id: str, display_type: str) -> dict:
    """
    ASC PPO V2 auto-deletes a screenshot set the moment it becomes empty
    (clearing screenshots one-by-one leaves the set in a transient empty
    state where subsequent uploads fail with 409 "appScreenshotSets doesn't
    exist"). To avoid that, delete the inherited set entirely and create a
    fresh empty one for our target display type. Any existing set for OTHER
    display types is left alone.
    """
    data = get(
        headers,
        f"/v1/appStoreVersionExperimentTreatmentLocalizations/{localization_id}/appScreenshotSets",
    )
    for s in data.get("data", []):
        if s["attributes"].get("screenshotDisplayType") == display_type:
            delete(headers, f"/v1/appScreenshotSets/{s['id']}")
            time.sleep(0.5)  # let ASC settle the cascade-delete
            break
    return create_screenshot_set(headers, localization_id, display_type)


# MARK: - Screenshot upload (3-step: reserve → PUT bytes → commit)

def _upload_once(headers: dict, set_id: str, file_path: Path,
                 file_data: bytes, file_size: int) -> str:
    """One full reserve → upload-bytes → commit cycle. Raises APIError on
    any non-2xx step. Caller is responsible for retrying the whole thing
    when ASC drops the screenshot reservation between steps."""
    # Step 1 — reserve a slot in the set
    reserve_body = {
        "data": {
            "type": "appScreenshots",
            "attributes": {
                "fileName": file_path.name,
                "fileSize": file_size,
            },
            "relationships": {
                "appScreenshotSet": {
                    "data": {"type": "appScreenshotSets", "id": set_id}
                }
            },
        }
    }
    reserve_resp = post(headers, "/v1/appScreenshots", reserve_body)["data"]
    screenshot_id: str = reserve_resp["id"]
    upload_operations = reserve_resp["attributes"]["uploadOperations"] or []

    # Step 2 — upload bytes per operation chunk
    for op in upload_operations:
        method = op["method"].upper()
        url = op["url"]
        offset = int(op["offset"])
        length = int(op["length"])
        chunk = file_data[offset : offset + length]
        op_headers = {h["name"]: h["value"] for h in op.get("requestHeaders", [])}
        r = requests.request(method, url, headers=op_headers, data=chunk)
        if not r.ok:
            raise APIError(
                f"Bytes upload for {file_path.name} failed: {r.status_code} {r.text}"
            )

    # Step 3 — commit IMMEDIATELY. Inserting any sleep before this PATCH
    # raises the chance the reservation gets garbage-collected on ASC's side
    # ("appScreenshots id ... does not exist" 404). The reservation seems
    # to live for ~10–15s tops after the bytes upload completes.
    checksum = hashlib.md5(file_data).hexdigest()
    commit_body = {
        "data": {
            "type": "appScreenshots",
            "id": screenshot_id,
            "attributes": {
                "uploaded": True,
                "sourceFileChecksum": checksum,
            },
        }
    }
    patch(headers, f"/v1/appScreenshots/{screenshot_id}", commit_body)
    return screenshot_id


def upload_screenshot(headers: dict, set_id: str, file_path: Path) -> str:
    """Wraps a full reserve+upload+commit cycle with retry, because ASC
    occasionally drops the reservation between bytes-upload and commit
    (returns 404 on the PATCH). On 404/409, restart the cycle with a fresh
    reservation up to MAX_ATTEMPTS times."""
    file_data = file_path.read_bytes()
    file_size = len(file_data)
    last_err: Optional[Exception] = None
    for attempt in range(4):
        try:
            return _upload_once(headers, set_id, file_path, file_data, file_size)
        except APIError as e:
            err_str = str(e)
            last_err = e
            # Only retry transient ASC drops (404/409). Anything else is
            # likely a real config issue — fail fast.
            if "404" not in err_str and "409" not in err_str:
                raise
            # Brief backoff before retrying. Don't make it long enough that
            # the next reservation can also age out.
            time.sleep(2.0 + attempt * 1.5)
            print(f"     ↻ retrying {file_path.name} (attempt {attempt+2})")
    raise APIError(f"Upload failed after 4 attempts for {file_path.name}: {last_err}")


# MARK: - Orchestration

def main() -> int:
    if not Path(KEY_PATH).exists():
        print(f"❌ Auth key not found at {KEY_PATH}", file=sys.stderr)
        return 1
    if not SCREENSHOTS_BASE.exists():
        print(f"❌ Screenshots dir not found: {SCREENSHOTS_BASE}", file=sys.stderr)
        return 1

    # Validate inputs locally
    expected_files = []
    for treatment_id, _ in TREATMENTS:
        for locale in LOCALES:
            folder = SCREENSHOTS_BASE / f"treatment_{treatment_id}" / locale
            if not folder.exists():
                print(f"❌ Missing folder: {folder}", file=sys.stderr)
                return 1
            pngs = sorted(folder.glob("*.png"))
            if not pngs:
                print(f"❌ No PNGs in {folder}", file=sys.stderr)
                return 1
            expected_files.extend(pngs)

    print(f"📂 Found {len(expected_files)} PNGs to upload across "
          f"{len(TREATMENTS)} treatments × {len(LOCALES)} locales.")

    # Auth
    token = make_token()
    headers = {"Authorization": f"Bearer {token}"}

    # Locate the app and the live version
    app = find_app(headers)
    print(f"📱 App: {app['attributes']['name']} (id={app['id']})")
    version = find_live_version(headers, app["id"])
    print(f"📦 Live version: v{version['attributes']['versionString']} "
          f"(id={version['id']})")

    # ASC only allows ONE experiment in draft per app at a time. Auto-clean
    # any in-progress drafts before creating ours so the script is idempotent.
    existing = list_existing_experiments(headers, app["id"])
    DRAFT_STATES = {"PREPARE_FOR_SUBMISSION", "READY_FOR_REVIEW", "WAITING_FOR_REVIEW",
                    "IN_REVIEW", "REJECTED", "ACCEPTED"}
    drafts = [e for e in existing if e["attributes"].get("state") in DRAFT_STATES]
    for d in drafts:
        d_name = d["attributes"].get("name", "?")
        d_state = d["attributes"].get("state", "?")
        print(f"🧹 Deleting existing experiment '{d_name}' (state={d_state}, id={d['id']})")
        delete(headers, f"/v2/appStoreVersionExperiments/{d['id']}")
        time.sleep(2)  # let ASC settle

    print(f"\n🧪 Creating experiment: {EXPERIMENT_NAME}")
    experiment = create_experiment(headers, app["id"], EXPERIMENT_NAME)
    experiment_id = experiment["id"]
    print(f"   experiment id={experiment_id}")

    # Create treatments + localizations + screenshot sets + uploads
    for treatment_id, treatment_label in TREATMENTS:
        print(f"\n▸ Treatment {treatment_id} — {treatment_label}")
        treatment = create_treatment(
            headers, experiment_id, f"Treatment {treatment_id} ({treatment_label})"
        )
        t_id = treatment["id"]

        for locale in LOCALES:
            localization = create_localization(headers, t_id, locale)
            l_id = localization["id"]
            # Delete-and-recreate the set instead of clear-screenshots-in-place,
            # because ASC PPO V2 auto-removes a set the moment its last clone
            # is deleted (causing 409 on the next POST /v1/appScreenshots).
            screenshot_set = reset_screenshot_set(headers, l_id, DISPLAY_TYPE)
            s_id = screenshot_set["id"]
            print(f"   [{locale}] fresh set ready (id={s_id})")

            folder = SCREENSHOTS_BASE / f"treatment_{treatment_id}" / locale
            pngs = sorted(folder.glob("*.png"))
            print(f"   [{locale}] uploading {len(pngs)} screenshots…")

            # ASC randomly returns 409 "appScreenshotSets doesn't exist" both
            # right after creating a set (propagation lag) and mid-upload (set
            # gets garbage-collected when the localization briefly looks empty).
            # Per-upload retry: re-resolve the set + sleep + try again.
            MAX_PER_UPLOAD = 4
            uploaded = 0
            while uploaded < len(pngs):
                png = pngs[uploaded]
                attempt = 0
                while True:
                    try:
                        upload_screenshot(headers, s_id, png)
                        print(f"     ✓ {png.name}")
                        uploaded += 1
                        break
                    except APIError as e:
                        attempt += 1
                        err = str(e)
                        is_transient = (
                            "doesn't exist" in err
                            or "RELATIONSHIP.INVALID" in err
                            or "NOT_FOUND" in err
                            or " 404" in err
                            or " 409" in err
                        )
                        if not is_transient or attempt >= MAX_PER_UPLOAD:
                            raise
                        backoff = 3 * attempt
                        print(f"     ↻ ASC dropped {png.name}; resetting set + sleep {backoff}s (attempt {attempt}/{MAX_PER_UPLOAD - 1})")
                        time.sleep(backoff)
                        # Hard-reset the set: delete + recreate. Just a find_or_create
                        # is not enough when ASC has actually GC'd the underlying
                        # appScreenshotSet (subsequent POSTs keep 409ing on the
                        # cached id even after find returns it).
                        screenshot_set = reset_screenshot_set(headers, l_id, DISPLAY_TYPE)
                        s_id = screenshot_set["id"]
                        # Already-uploaded screenshots in the OLD set are gone now,
                        # so restart this locale from screenshot 0.
                        uploaded = 0

    print(f"\n✅ Experiment created with {len(TREATMENTS) * len(LOCALES) * 5} screenshots uploaded.")
    print(
        f"   Open App Store Connect → My Apps → [your app] → Product Page Optimization\n"
        f"   to review the experiment '{EXPERIMENT_NAME}' and start it when ready."
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
