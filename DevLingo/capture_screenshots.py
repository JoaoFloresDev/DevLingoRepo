#!/usr/bin/env python3
"""
DevLingo Screenshot Capture Script
Captures screenshots in English, Portuguese, and Spanish using iOS Simulator.
"""

import subprocess
import time
import os
import json
import shutil

PROJECT_DIR = "/Users/joaoflores/Documents/GambitStudio/DevLingoRepo/DevLingo"
OUTPUT_DIR = os.path.join(PROJECT_DIR, "Screenshots")
BUNDLE_ID = "com.gambitstudio.devlingo"
DEVICE_TYPE = "com.apple.CoreSimulator.SimDeviceType.iPhone-16-Pro-Max"
RUNTIME = None  # Will be auto-detected

LANGUAGES = {
    "en-US": {"lang": "en", "region": "US"},
    "pt-BR": {"lang": "pt-BR", "region": "BR"},
    "es-ES": {"lang": "es", "region": "ES"},
}

SCREENS = [
    ("01_Home", 0),        # Tab 0 = Home
    ("02_Categories", 1),  # Tab 1 = Categories
    ("03_History", 2),     # Tab 2 = History
    ("04_Profile", 3),     # Tab 3 = Profile
]


def run(cmd, timeout=60):
    """Run shell command and return output."""
    result = subprocess.run(cmd, shell=True, capture_output=True, text=True, timeout=timeout)
    return result.stdout.strip(), result.stderr.strip(), result.returncode


def get_runtime():
    """Get latest iOS runtime."""
    out, _, _ = run("xcrun simctl list runtimes -j")
    data = json.loads(out)
    for rt in reversed(data.get("runtimes", [])):
        if "iOS" in rt.get("name", "") and rt.get("isAvailable", False):
            return rt["identifier"]
    return None


def create_simulator(name):
    """Create a new simulator device."""
    runtime = get_runtime()
    if not runtime:
        print("ERROR: No iOS runtime found!")
        return None
    out, err, code = run(f'xcrun simctl create "{name}" {DEVICE_TYPE} {runtime}')
    if code != 0:
        print(f"Error creating sim: {err}")
        return None
    return out.strip()


def delete_simulator(udid):
    """Delete simulator."""
    run(f"xcrun simctl delete {udid}")


def boot_simulator(udid):
    """Boot simulator and wait for it."""
    run(f"xcrun simctl boot {udid}")
    time.sleep(2)
    # Wait until booted
    for _ in range(30):
        out, _, _ = run(f"xcrun simctl list devices -j")
        data = json.loads(out)
        for runtime_devs in data.get("devices", {}).values():
            for dev in runtime_devs:
                if dev["udid"] == udid and dev["state"] == "Booted":
                    return True
        time.sleep(1)
    return False


def shutdown_simulator(udid):
    """Shutdown simulator."""
    run(f"xcrun simctl shutdown {udid}")
    time.sleep(2)


def set_language(udid, lang, region):
    """Set simulator language and region."""
    # Use simctl spawn to set preferences
    run(f'xcrun simctl spawn {udid} defaults write "Apple Global Domain" AppleLanguages -array "{lang}"')
    run(f'xcrun simctl spawn {udid} defaults write "Apple Global Domain" AppleLocale "{lang}_{region}"')


def install_app(udid):
    """Install the built app on simulator."""
    # Find the built .app
    app_path = None
    derived = os.path.expanduser("~/Library/Developer/Xcode/DerivedData")
    for d in os.listdir(derived):
        if d.startswith("DevLingo-"):
            candidate = os.path.join(derived, d, "Build/Products/Debug-iphonesimulator/DevLingo.app")
            if os.path.exists(candidate):
                app_path = candidate
                break

    if not app_path:
        print("ERROR: Could not find built DevLingo.app")
        return False

    out, err, code = run(f'xcrun simctl install {udid} "{app_path}"')
    if code != 0:
        print(f"Install error: {err}")
        return False
    return True


def launch_app(udid):
    """Launch app and wait for it to load."""
    run(f"xcrun simctl launch {udid} {BUNDLE_ID}")
    time.sleep(4)  # Wait for app to fully load with mock data


def terminate_app(udid):
    """Terminate app."""
    run(f"xcrun simctl terminate {udid} {BUNDLE_ID}")
    time.sleep(1)


def take_screenshot(udid, output_path):
    """Capture a screenshot."""
    run(f'xcrun simctl io {udid} screenshot "{output_path}"')


def tap_tab(udid, tab_index):
    """Simulate tapping a tab bar item by sending coordinates.
    iPhone 16 Pro Max: 430x932 logical points
    Tab bar is at the bottom, ~y=900, tabs evenly spaced.
    4 tabs: x positions at ~54, 161, 269, 376 (for 430 width, 4 tabs)
    """
    width = 430
    tab_count = 4
    spacing = width / tab_count
    x = int(spacing * tab_index + spacing / 2)
    y = 900  # Tab bar area

    # Use simctl to send a tap - we need to use AppleScript or other method
    # simctl doesn't have a direct tap command, so we use status bar tap workaround
    # Instead, let's use the approach of relaunching with deep link or using XCTest
    pass


def capture_with_uitest(udid, lang, region, output_folder):
    """Use XCTest to capture screenshots with proper navigation."""
    os.makedirs(output_folder, exist_ok=True)

    # Set language before booting
    set_language(udid, lang, region)

    # Launch app with onboarding skipped
    terminate_app(udid)
    time.sleep(1)

    # Set UserDefaults to skip onboarding
    run(f'xcrun simctl spawn {udid} defaults write {BUNDLE_ID} hasCompletedOnboarding -bool true')
    time.sleep(0.5)

    # Launch
    launch_app(udid)
    time.sleep(5)  # Extra wait for mock data to load

    # Screenshot 1: Home
    take_screenshot(udid, os.path.join(output_folder, "01_Home.png"))
    print(f"    Captured: 01_Home.png")

    # We can't easily tap tabs via simctl, so we'll use XCUITest
    # But we can use the keyboard shortcut or other creative methods
    # Alternative: Use `simctl` status bar and coordinate-based approach

    # For tab navigation, we'll use the `xcrun simctl` keyboard input
    # Actually, the simplest reliable method is to run XCUITest

    return True


def run_uitest_for_language(lang_code, lang, region, output_folder):
    """Run UI test for a specific language and extract screenshots."""
    os.makedirs(output_folder, exist_ok=True)

    derived = os.path.join(PROJECT_DIR, "DerivedScreenshots")

    print(f"    Running UI tests...")
    cmd = (
        f'xcodebuild test '
        f'-project "{PROJECT_DIR}/DevLingo.xcodeproj" '
        f'-scheme DevLingo '
        f'-destination "platform=iOS Simulator,name=iPhone 16 Pro Max" '
        f'-testLanguage "{lang}" '
        f'-testRegion "{region}" '
        f'-only-testing:DevLingoUITests/ScreenshotTests/testCaptureAllScreens '
        f'-derivedDataPath "{derived}" '
        f'2>&1'
    )

    out, err, code = run(cmd, timeout=300)

    # Find test attachments (screenshots)
    # They're stored in the xcresult bundle
    xcresult = None
    for root, dirs, files in os.walk(derived):
        for d in dirs:
            if d.endswith(".xcresult"):
                xcresult = os.path.join(root, d)
                break
        if xcresult:
            break

    if xcresult:
        # Export attachments from xcresult
        export_screenshots_from_xcresult(xcresult, output_folder)
    else:
        print(f"    WARNING: No xcresult found, checking for PNG files...")
        # Fallback: find PNGs in derived data
        for root, dirs, files in os.walk(derived):
            for f in files:
                if f.endswith(".png") and not f.startswith("."):
                    src = os.path.join(root, f)
                    dst = os.path.join(output_folder, f)
                    shutil.copy2(src, dst)
                    print(f"    Copied: {f}")

    # Cleanup derived data
    if os.path.exists(derived):
        shutil.rmtree(derived, ignore_errors=True)

    return code == 0


def export_screenshots_from_xcresult(xcresult_path, output_folder):
    """Export screenshot attachments from xcresult bundle."""
    # Get the test result graph
    out, _, _ = run(f'xcrun xcresulttool get --path "{xcresult_path}" --format json', timeout=30)
    if not out:
        print("    Could not read xcresult")
        return

    try:
        data = json.loads(out)
    except json.JSONDecodeError:
        print("    Could not parse xcresult JSON")
        return

    # Find attachment references recursively
    attachment_ids = []
    find_attachments(data, attachment_ids)

    if not attachment_ids:
        print("    No attachments found in xcresult, trying direct file search...")
        # Direct search for PNG files
        for root, dirs, files in os.walk(xcresult_path):
            for f in files:
                if f.endswith(".png"):
                    src = os.path.join(root, f)
                    dst = os.path.join(output_folder, f)
                    shutil.copy2(src, dst)
                    print(f"    Direct copy: {f}")
        return

    # Export each attachment
    for i, (name, ref_id) in enumerate(attachment_ids):
        safe_name = name if name else f"screenshot_{i:02d}"
        if not safe_name.endswith(".png"):
            safe_name += ".png"
        output_path = os.path.join(output_folder, safe_name)

        run(
            f'xcrun xcresulttool export --path "{xcresult_path}" '
            f'--id "{ref_id}" --output-path "{output_path}" --type file',
            timeout=15
        )
        if os.path.exists(output_path):
            print(f"    Exported: {safe_name}")


def find_attachments(obj, results, depth=0):
    """Recursively find attachment references in xcresult JSON."""
    if depth > 20:
        return
    if isinstance(obj, dict):
        # Check if this is an attachment
        if obj.get("_type", {}).get("_name") == "ActionTestAttachment":
            name = obj.get("name", {}).get("_value", "")
            payload_ref = obj.get("payloadRef", {}).get("id", {}).get("_value", "")
            if payload_ref:
                results.append((name, payload_ref))

        # Recurse into all values
        for v in obj.values():
            find_attachments(v, results, depth + 1)
    elif isinstance(obj, list):
        for item in obj:
            find_attachments(item, results, depth + 1)


def main():
    # Clean output
    if os.path.exists(OUTPUT_DIR):
        shutil.rmtree(OUTPUT_DIR)
    os.makedirs(OUTPUT_DIR)

    print("=" * 60)
    print("  DevLingo Screenshot Capture")
    print("=" * 60)

    for lang_code, settings in LANGUAGES.items():
        print(f"\n{'=' * 60}")
        print(f"  Language: {lang_code}")
        print(f"{'=' * 60}")

        output_folder = os.path.join(OUTPUT_DIR, lang_code)
        success = run_uitest_for_language(
            lang_code,
            settings["lang"],
            settings["region"],
            output_folder
        )

        # Count screenshots
        if os.path.exists(output_folder):
            pngs = [f for f in os.listdir(output_folder) if f.endswith(".png")]
            print(f"  Total screenshots for {lang_code}: {len(pngs)}")
        else:
            print(f"  WARNING: No screenshots captured for {lang_code}")

    # Summary
    print(f"\n{'=' * 60}")
    print(f"  Screenshots saved to: {OUTPUT_DIR}")
    print(f"{'=' * 60}")

    for lang_code in LANGUAGES:
        folder = os.path.join(OUTPUT_DIR, lang_code)
        if os.path.exists(folder):
            files = sorted(os.listdir(folder))
            print(f"\n  {lang_code}/")
            for f in files:
                size = os.path.getsize(os.path.join(folder, f))
                print(f"    {f} ({size // 1024}KB)")


if __name__ == "__main__":
    main()
