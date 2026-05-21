#!/usr/bin/env python3
"""Push version metadata to App Store Connect (description, keywords, release notes, per-locale).

Populates ASC fields that the CI build upload (xcodebuild archive + exportArchive)
does NOT touch. Pairs with `.github/workflows/archive-upload.yml`.

HOW TO USE FOR NEXT RELEASE:
  1. Update RELEASE_NOTES + PROMO dicts for the new version.
  2. Optionally rename target version by changing the PATCH block at step 1.
  3. Run: `python3 fastlane/asc_publish.py`

CURRENT STATE (v1.5.0):
  - 7 locales: en-US, pt-BR, es-ES, es-MX, fr-FR, de-DE, it
  - fr-FR, de-DE, it added 2026-05-20 with full description + keywords (~95-100 chars)

The script is idempotent: re-running PATCHes the same fields, no duplicates.
Requires ASC API key at $HOME/private_keys/AuthKey_67JG58Q6XH.p8.
"""
import jwt, time, urllib.request, urllib.error, json, sys

KEY_ID = "67JG58Q6XH"
ISSUER_ID = "98c49316-b223-4d64-955d-b55ae76ab9d2"
KEY_PATH = "/Users/joaoflores/private_keys/AuthKey_67JG58Q6XH.p8"
APP_ID = "6759974641"
SUPPORT_URL = "https://gambitstudiotech.com/"

n = int(time.time())
TOKEN = jwt.encode(
    {"iss": ISSUER_ID, "iat": n, "exp": n + 1200, "aud": "appstoreconnect-v1"},
    open(KEY_PATH).read(), algorithm="ES256",
    headers={"kid": KEY_ID, "typ": "JWT"}
)

def req(method, url, body=None):
    headers = {"Authorization": f"Bearer {TOKEN}", "Content-Type": "application/json"}
    data = json.dumps(body).encode("utf-8") if body is not None else None
    r = urllib.request.Request(url, data=data, method=method, headers=headers)
    try:
        resp = urllib.request.urlopen(r)
        raw = resp.read()
        return json.loads(raw) if raw else {}
    except urllib.error.HTTPError as e:
        print(f"  ERROR {e.code}: {e.read().decode()}", file=sys.stderr)
        raise

# Release notes (approved PT-BR + translations)
RELEASE_NOTES = {
    "pt-BR": (
        "WWDC 2026 chegou ao Devlingo! Nova categoria com 100 frases técnicas curadas do ecossistema Apple — SwiftUI, Swift Concurrency, App Intents, Vision Pro e Apple Intelligence.\n\n"
        "Widget interativo na tela inicial: folheie as frases do dia sem abrir o app, com toques que respeitam as HIG da Apple.\n\n"
        "Modo claro e escuro nativos acompanhando o iPhone automaticamente."
    ),
    "en-US": (
        "WWDC 2026 arrives in Devlingo! New category with 100 curated technical phrases from the Apple ecosystem — SwiftUI, Swift Concurrency, App Intents, Vision Pro, and Apple Intelligence.\n\n"
        "Interactive home screen widget: flip through today's phrases without opening the app, with taps that follow Apple's HIG.\n\n"
        "Native light and dark mode automatically following your iPhone."
    ),
    "es-ES": (
        "¡WWDC 2026 llega a Devlingo! Nueva categoría con 100 frases técnicas curadas del ecosistema Apple — SwiftUI, Swift Concurrency, App Intents, Vision Pro y Apple Intelligence.\n\n"
        "Widget interactivo en la pantalla de inicio: hojea las frases del día sin abrir la app, con toques que respetan las HIG de Apple.\n\n"
        "Modo claro y oscuro nativos siguiendo a tu iPhone automáticamente."
    ),
    "es-MX": (
        "¡WWDC 2026 llega a Devlingo! Nueva categoría con 100 frases técnicas curadas del ecosistema Apple — SwiftUI, Swift Concurrency, App Intents, Vision Pro y Apple Intelligence.\n\n"
        "Widget interactivo en la pantalla de inicio: hojea las frases del día sin abrir la app, con toques que respetan las HIG de Apple.\n\n"
        "Modo claro y oscuro nativos siguiendo a tu iPhone automáticamente."
    ),
    "fr-FR": (
        "La WWDC 2026 arrive sur Devlingo ! Nouvelle catégorie avec 100 phrases techniques sélectionnées de l'écosystème Apple — SwiftUI, Swift Concurrency, App Intents, Vision Pro et Apple Intelligence.\n\n"
        "Widget interactif sur l'écran d'accueil : feuilletez les phrases du jour sans ouvrir l'app, avec des touches respectant les HIG d'Apple.\n\n"
        "Mode clair et sombre natifs qui suivent automatiquement votre iPhone."
    ),
    "de-DE": (
        "WWDC 2026 ist auf Devlingo angekommen! Neue Kategorie mit 100 kuratierten technischen Sätzen aus dem Apple-Ökosystem — SwiftUI, Swift Concurrency, App Intents, Vision Pro und Apple Intelligence.\n\n"
        "Interaktives Widget auf dem Home-Bildschirm: Blättere durch die Sätze des Tages, ohne die App zu öffnen — mit Tipp-Targets, die Apples HIG respektieren.\n\n"
        "Nativer Hell- und Dunkelmodus, der sich automatisch deinem iPhone anpasst."
    ),
    "it": (
        "WWDC 2026 arriva su Devlingo! Nuova categoria con 100 frasi tecniche curate dall'ecosistema Apple — SwiftUI, Swift Concurrency, App Intents, Vision Pro e Apple Intelligence.\n\n"
        "Widget interattivo sulla schermata Home: sfoglia le frasi del giorno senza aprire l'app, con tocchi che rispettano le HIG di Apple.\n\n"
        "Modalità chiara e scura native che seguono automaticamente il tuo iPhone."
    ),
}

# Full description per new locale
DESCRIPTIONS = {
    "fr-FR": """Tu travailles à distance pour une entreprise américaine, mais l'anglais reste une barrière dans ta communication quotidienne. Devlingo a été créé spécifiquement pour des devs comme toi.

Contrairement aux apps de langues génériques, Devlingo enseigne les phrases et expressions exactes que tu utilises chaque jour dans le travail tech à distance. Pas de superflu, pas de vocabulaire touristique, pas de dialogues au restaurant. Juste l'anglais qui compte vraiment pour ta carrière.


POURQUOI DEVLINGO ?

Tu sais déjà coder. Tu as déjà les compétences techniques. Ce qui te manque, c'est la confiance pour communiquer clairement en anglais au travail. Devlingo comble ce vide avec un contenu 100% centré sur le monde des devs.


CE QUE TU VAS APPRENDRE

Plus de 3 600 phrases organisées en 12 catégories pratiques tirées de ta routine professionnelle :

- Daily Standup : communique progrès, blocages et plans avec clarté.
- Code Review : donne et reçois des retours techniques avec professionnalisme.
- Slack et messagerie : maîtrise la communication asynchrone, informelle mais claire.
- E-mail professionnel : écris des e-mails polis, clairs et précis.
- Réunions : participe activement aux calls, plannings et rétrospectives.
- Discussions techniques : débats sur architecture, trade-offs et décisions.
- Pull Requests : décris, commente et approuve des PR avec le bon vocabulaire.
- Bug Reports : signale et discute des bugs avec précision technique.
- Pair Programming : collabore en temps réel avec fluidité.
- Entretiens : prépare-toi aux entretiens techniques en anglais avec confiance.
- Discussions casual : rejoins naturellement les conversations de pause de ton équipe.
- Documentation : rédige docs, README et specs comme un natif.


COMMENT ÇA MARCHE

10 nouvelles phrases par jour. Simple, régulier, jamais écrasant. Chaque phrase vient avec un contexte concret, des indications de prononciation et des exemples pratiques. En quelques minutes par jour, tu construis un vocabulaire solide et fonctionnel.


WIDGET D'ÉCRAN D'ACCUEIL

Ajoute le widget Devlingo à l'écran d'accueil de ton iPhone et vois la phrase du jour sans même ouvrir l'app. Une façon légère et constante de continuer à apprendre pendant ta journée de travail.


SYSTÈME DE STREAK

Maintiens ta série de jours consécutifs et suis ta progression dans le temps. Pense à ça comme à ton graphe de contributions GitHub : la régularité construit les résultats. Ne casse pas la chaîne.


10 LANGUES SOURCES

Devlingo est disponible pour les locuteurs de portugais, espagnol, mandarin, hindi, japonais, coréen, français, allemand, italien et polonais. Peu importe d'où tu viens — si tu travailles dans la tech, Devlingo est pour toi.


POUR QUI EST DEVLINGO

- Devs travaillant à distance pour des entreprises basées aux États-Unis.
- Programmeurs qui veulent améliorer leur anglais professionnel.
- Pros de la tech qui préparent des entretiens internationaux.
- Devs avec un anglais intermédiaire qui veulent monter d'un niveau en contexte pro.
- Toute personne dans la tech qui veut communiquer avec plus de confiance dans des équipes globales.


Arrête de bloquer pendant les standups. Arrête de réécrire trois fois ce commentaire de PR. Arrête de rester silencieux en réunion parce que tu n'as pas trouvé les bons mots.

=================

Privacy Policy: https://drive.google.com/file/d/147xkp4cekrxhrBYZnzV-J4PzCSqkix7t/view?usp=sharing

Terms of Use: https://www.apple.com/legal/internet-services/itunes/dev/stdeula/
""",
    "de-DE": """Du arbeitest remote für ein US-Unternehmen, aber Englisch fühlt sich in der täglichen Kommunikation immer noch wie eine Hürde an. Devlingo wurde speziell für Devs wie dich entwickelt.

Anders als generische Sprach-Apps lehrt Devlingo genau die Sätze und Wendungen, die du täglich in der remote Tech-Arbeit nutzt. Kein Schnickschnack, kein Touristen-Vokabular, keine Restaurant-Dialoge. Nur das Englisch, auf das es wirklich für deine Karriere ankommt.


WARUM DEVLINGO?

Du kannst schon programmieren. Du hast die technischen Skills. Was fehlt, ist die Sicherheit, im Job klar auf Englisch zu kommunizieren. Devlingo schließt diese Lücke mit Inhalten, die zu 100% auf die Dev-Welt fokussiert sind.


WAS DU LERNST

Über 3.600 Sätze, organisiert in 12 praktischen Kategorien aus deinem Berufsalltag:

- Daily Standup: Kommuniziere Fortschritt, Blocker und Pläne klar.
- Code Review: Gib und erhalte technisches Feedback professionell.
- Slack und Messaging: Beherrsche asynchrone Kommunikation, informell und doch klar.
- Berufliche E-Mails: Schreibe höflich, klar und auf den Punkt.
- Meetings: Beteilige dich aktiv an Calls, Plannings und Retros.
- Technische Diskussionen: Diskutiere Architektur, Trade-offs und Entscheidungen.
- Pull Requests: Beschreibe, kommentiere und approve PRs mit dem richtigen Vokabular.
- Bug Reports: Melde und diskutiere Bugs mit technischer Präzision.
- Pair Programming: Arbeite in Echtzeit flüssig zusammen.
- Interviews: Bereite dich selbstbewusst auf englische Tech-Interviews vor.
- Casual Chat: Mische dich natürlich in die Kaffee-Gespräche deines Teams.
- Documentation: Schreibe Docs, READMEs und Specs wie ein Native Speaker.


WIE ES FUNKTIONIERT

10 neue Sätze pro Tag. Einfach, konstant, nie überwältigend. Jeder Satz kommt mit echtem Kontext, Aussprache-Hinweisen und praktischen Beispielen. In wenigen Minuten am Tag baust du ein solides, funktionales Vokabular auf.


HOME-SCREEN-WIDGET

Füge das Devlingo-Widget zum Home-Bildschirm deines iPhones hinzu und sieh den Satz des Tages, ohne die App zu öffnen. Eine leichte, konstante Möglichkeit, während deines Arbeitstags weiterzulernen.


STREAK-SYSTEM

Halte deine Serie aufeinanderfolgender Tage und verfolge deinen Fortschritt im Zeitverlauf. Stell dir das wie deinen GitHub-Contribution-Graph vor: Konstanz baut Ergebnisse. Reiß die Kette nicht ab.


10 AUSGANGSSPRACHEN

Devlingo gibt es für Sprecher von Portugiesisch, Spanisch, Mandarin, Hindi, Japanisch, Koreanisch, Französisch, Deutsch, Italienisch und Polnisch. Egal woher du kommst — wenn du in der Tech arbeitest, ist Devlingo für dich.


FÜR WEN IST DEVLINGO

- Devs, die remote für US-Unternehmen arbeiten.
- Programmiererinnen und Programmierer, die ihr Business-Englisch verbessern wollen.
- Tech-Profis, die sich auf internationale Interviews vorbereiten.
- Devs mit mittlerem Englischlevel, die im Berufskontext aufsteigen wollen.
- Alle in der Tech, die mit mehr Selbstvertrauen in globalen Teams kommunizieren wollen.


Hör auf, im Standup zu blockieren. Hör auf, denselben PR-Kommentar dreimal umzuschreiben. Hör auf, im Meeting zu schweigen, weil dir die richtigen Worte fehlen.

=================

Privacy Policy: https://drive.google.com/file/d/147xkp4cekrxhrBYZnzV-J4PzCSqkix7t/view?usp=sharing

Terms of Use: https://www.apple.com/legal/internet-services/itunes/dev/stdeula/
""",
    "it": """Lavori da remoto per un'azienda statunitense, ma l'inglese resta una barriera nella tua comunicazione quotidiana. Devlingo è stato creato proprio per dev come te.

A differenza delle app di lingue generiche, Devlingo insegna le frasi ed espressioni esatte che usi ogni giorno nel lavoro tech da remoto. Niente fronzoli, niente vocabolario da turista, niente dialoghi al ristorante. Solo l'inglese che davvero conta per la tua carriera.


PERCHÉ DEVLINGO?

Sai già programmare. Hai già le competenze tecniche. Quello che manca è la sicurezza di comunicare chiaramente in inglese al lavoro. Devlingo colma questa lacuna con contenuti 100% focalizzati sul mondo dei dev.


COSA IMPARERAI

Oltre 3.600 frasi organizzate in 12 categorie pratiche tratte dalla tua routine professionale:

- Daily Standup: comunica progressi, blocchi e piani con chiarezza.
- Code Review: dai e ricevi feedback tecnici in modo professionale.
- Slack e messaggi: padroneggia la comunicazione asincrona, informale ma chiara.
- E-mail professionali: scrivi e-mail educate, chiare e dirette al punto.
- Riunioni: partecipa attivamente a call, planning e retrospettive.
- Discussioni tecniche: discuti di architettura, trade-off e decisioni.
- Pull Request: descrivi, commenta e approva PR con il giusto vocabolario.
- Bug Report: segnala e discuti bug con precisione tecnica.
- Pair Programming: collabora in tempo reale con scioltezza.
- Colloqui: preparati ai colloqui tecnici in inglese con sicurezza.
- Chiacchiere informali: unisciti naturalmente alle conversazioni alla macchinetta del tuo team.
- Documentation: scrivi docs, README e specs come un madrelingua.


COME FUNZIONA

10 nuove frasi al giorno. Semplice, costante, mai opprimente. Ogni frase arriva con contesto reale, indicazioni di pronuncia ed esempi pratici. In pochi minuti al giorno costruisci un vocabolario solido e funzionale.


WIDGET DELLA SCHERMATA HOME

Aggiungi il widget Devlingo alla schermata Home del tuo iPhone e vedi la frase del giorno senza nemmeno aprire l'app. Un modo leggero e costante di continuare a imparare durante la giornata di lavoro.


SISTEMA DI STREAK

Mantieni la tua serie di giorni consecutivi e segui i tuoi progressi nel tempo. Pensalo come il tuo grafico di contributi su GitHub: la costanza costruisce i risultati. Non interrompere la catena.


10 LINGUE SORGENTE

Devlingo è disponibile per parlanti di portoghese, spagnolo, mandarino, hindi, giapponese, coreano, francese, tedesco, italiano e polacco. Da qualunque parte tu venga — se lavori nella tech, Devlingo è per te.


A CHI È RIVOLTO DEVLINGO

- Dev che lavorano da remoto per aziende statunitensi.
- Programmatori che vogliono migliorare il loro inglese al lavoro.
- Professionisti della tech in preparazione a colloqui internazionali.
- Dev con inglese intermedio che vogliono salire di livello in contesto pro.
- Chiunque nella tech voglia comunicare con più sicurezza in team globali.


Smetti di bloccarti negli standup. Smetti di riscrivere tre volte quel commento al PR. Smetti di stare in silenzio nelle riunioni perché non trovi le parole giuste.

=================

Privacy Policy: https://drive.google.com/file/d/147xkp4cekrxhrBYZnzV-J4PzCSqkix7t/view?usp=sharing

Terms of Use: https://www.apple.com/legal/internet-services/itunes/dev/stdeula/
""",
}

# AppInfo level (name + subtitle)
NEW_APP_INFO = {
    "fr-FR": {"name": "Devlingo: Anglais pour devs", "subtitle": "Anglais pour devs en remote"},
    "de-DE": {"name": "Devlingo: Englisch für Devs", "subtitle": "Englisch für Remote-Entwickler"},
    "it":    {"name": "Devlingo: Inglese per dev",  "subtitle": "Inglese per dev in remoto"},
}

# Keywords packed near 100 chars for each new locale
NEW_KEYWORDS = {
    "fr-FR": "anglais,développeur,programmation,remote,tech,phrases,daily,standup,slack,réunion,travail,dev,it",
    "de-DE": "englisch,entwickler,programmierung,remote,tech,sätze,daily,standup,slack,meeting,arbeit,dev,it",
    "it":    "inglese,sviluppatore,programmazione,remoto,tech,frasi,daily,standup,slack,riunione,lavoro,dev,it",
}

# Promo (170 chars) - WWDC pitch, optional but recommended
PROMO = {
    "en-US": "WWDC 2026 update: 100 new technical phrases on SwiftUI, Swift Concurrency, App Intents, Vision Pro and Apple Intelligence. Interactive widget + light mode.",
    "pt-BR": "Edição WWDC 2026: 100 frases técnicas novas de SwiftUI, Swift Concurrency, App Intents, Vision Pro e Apple Intelligence. Widget interativo + modo claro.",
    "es-ES": "Edición WWDC 2026: 100 frases técnicas nuevas sobre SwiftUI, Swift Concurrency, App Intents, Vision Pro y Apple Intelligence. Widget interactivo + modo claro.",
    "es-MX": "Edición WWDC 2026: 100 frases técnicas nuevas sobre SwiftUI, Swift Concurrency, App Intents, Vision Pro y Apple Intelligence. Widget interactivo + modo claro.",
    "fr-FR": "Édition WWDC 2026 : 100 phrases techniques sur SwiftUI, Swift Concurrency, App Intents, Vision Pro et Apple Intelligence. Widget interactif + mode clair.",
    "de-DE": "WWDC 2026 Update: 100 neue technische Sätze zu SwiftUI, Swift Concurrency, App Intents, Vision Pro und Apple Intelligence. Interaktives Widget + Hellmodus.",
    "it":    "Edizione WWDC 2026: 100 frasi tecniche su SwiftUI, Swift Concurrency, App Intents, Vision Pro e Apple Intelligence. Widget interattivo + modalità chiara.",
}

# Verify keyword length <= 100
for loc, kw in NEW_KEYWORDS.items():
    print(f"keywords[{loc}] = {len(kw)} chars")
    assert len(kw) <= 100, f"keywords too long for {loc}"

# Verify name/subtitle <= 30
for loc, ai in NEW_APP_INFO.items():
    assert len(ai["name"]) <= 30, f"name too long for {loc}: {len(ai['name'])}"
    assert len(ai["subtitle"]) <= 30, f"subtitle too long for {loc}: {len(ai['subtitle'])}"
    print(f"appInfo[{loc}] name={len(ai['name'])} subtitle={len(ai['subtitle'])}")

# Step 1: Find version, rename to 1.5.0
def get(url):
    return json.loads(urllib.request.urlopen(
        urllib.request.Request(url, headers={"Authorization": f"Bearer {TOKEN}"})
    ).read())

print("\n[1/5] Finding editable version...")
vs = get(f"https://api.appstoreconnect.apple.com/v1/apps/{APP_ID}/appStoreVersions?filter[versionString]=1.4.0")
if not vs["data"]:
    vs = get(f"https://api.appstoreconnect.apple.com/v1/apps/{APP_ID}/appStoreVersions?filter[appStoreState]=PREPARE_FOR_SUBMISSION")
v_id = vs["data"][0]["id"]
cur_string = vs["data"][0]["attributes"]["versionString"]
print(f"  Editable version: {cur_string} (id={v_id})")

if cur_string != "1.5.0":
    print(f"  Renaming {cur_string} -> 1.5.0")
    req("PATCH", f"https://api.appstoreconnect.apple.com/v1/appStoreVersions/{v_id}", {
        "data": {
            "type": "appStoreVersions",
            "id": v_id,
            "attributes": {"versionString": "1.5.0"}
        }
    })

# Step 2: Get current AppInfo for adding new app-level locales
print("\n[2/5] Fetching AppInfo for app-level locales...")
infos = get(f"https://api.appstoreconnect.apple.com/v1/apps/{APP_ID}/appInfos")
# Need the EDITABLE appInfo (matches the inflight version)
editable_appinfo_id = None
for ai in infos["data"]:
    state = ai["attributes"].get("appStoreState") or ai["attributes"].get("state")
    print(f"  AppInfo id={ai['id']} state={state}")
    if state in ("PREPARE_FOR_SUBMISSION", "DEVELOPER_REJECTED", "REJECTED", "METADATA_REJECTED", "INVALID_BINARY", "WAITING_FOR_REVIEW", "READY_FOR_REVIEW"):
        editable_appinfo_id = ai["id"]
        break
if not editable_appinfo_id:
    editable_appinfo_id = infos["data"][0]["id"]
print(f"  Using AppInfo: {editable_appinfo_id}")

# List existing app-level locales
existing_app_info_locs = {}
ail = get(f"https://api.appstoreconnect.apple.com/v1/appInfos/{editable_appinfo_id}/appInfoLocalizations")
for l in ail["data"]:
    existing_app_info_locs[l["attributes"]["locale"]] = l["id"]
print(f"  Existing app-level locales: {list(existing_app_info_locs.keys())}")

# Step 3: Create new app-level locales for fr-FR, de-DE, it
print("\n[3/5] Creating new app-level locales (name/subtitle)...")
for locale, content in NEW_APP_INFO.items():
    if locale in existing_app_info_locs:
        print(f"  {locale} exists, skipping")
        continue
    print(f"  Creating {locale}...")
    body = {
        "data": {
            "type": "appInfoLocalizations",
            "attributes": {
                "locale": locale,
                "name": content["name"],
                "subtitle": content["subtitle"],
            },
            "relationships": {
                "appInfo": {"data": {"type": "appInfos", "id": editable_appinfo_id}}
            }
        }
    }
    req("POST", "https://api.appstoreconnect.apple.com/v1/appInfoLocalizations", body)
    print(f"    {locale} created")

# Step 4: Get existing version-level localizations + update release notes + promo
print("\n[4/5] Updating per-version localizations (release notes + promo)...")
locs = get(f"https://api.appstoreconnect.apple.com/v1/appStoreVersions/{v_id}/appStoreVersionLocalizations")
existing_version_locs = {l["attributes"]["locale"]: l["id"] for l in locs["data"]}
print(f"  Existing version-level locales: {list(existing_version_locs.keys())}")

for locale, loc_id in existing_version_locs.items():
    notes = RELEASE_NOTES.get(locale)
    promo = PROMO.get(locale)
    if not notes:
        continue
    print(f"  Updating {locale} release_notes ({len(notes)} chars) + promo ({len(promo) if promo else 0} chars)")
    attrs = {"whatsNew": notes}
    if promo:
        attrs["promotionalText"] = promo
    req("PATCH", f"https://api.appstoreconnect.apple.com/v1/appStoreVersionLocalizations/{loc_id}", {
        "data": {
            "type": "appStoreVersionLocalizations",
            "id": loc_id,
            "attributes": attrs
        }
    })
    print(f"    {locale} updated")

# Step 5: Create new version-level localizations for fr-FR, de-DE, it
print("\n[5/5] Creating new version-level localizations (description/keywords/notes/promo/support)...")
for locale in NEW_APP_INFO.keys():
    if locale in existing_version_locs:
        print(f"  {locale} version-loc exists, skipping create (already updated above)")
        continue
    print(f"  Creating {locale} version-localization...")
    body = {
        "data": {
            "type": "appStoreVersionLocalizations",
            "attributes": {
                "locale": locale,
                "description": DESCRIPTIONS[locale],
                "keywords": NEW_KEYWORDS[locale],
                "promotionalText": PROMO[locale],
                "whatsNew": RELEASE_NOTES[locale],
                "supportUrl": SUPPORT_URL,
            },
            "relationships": {
                "appStoreVersion": {"data": {"type": "appStoreVersions", "id": v_id}}
            }
        }
    }
    req("POST", "https://api.appstoreconnect.apple.com/v1/appStoreVersionLocalizations", body)
    print(f"    {locale} version-loc created")

print("\n✅ Done. Check ASC web UI to verify.")
