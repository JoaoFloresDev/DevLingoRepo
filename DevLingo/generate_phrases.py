#!/usr/bin/env python3
"""Generate DevLingo phrase JSON files."""
import json
import os

OUTPUT_DIR = "/Users/joaoflores/Documents/GambitStudio/DevLingo/DevLingo/Data/Phrases"

# We'll build phrase lists then write them
slack_phrases = []
email_phrases = []

###############################################################################
# SLACK PHRASES — EASY (001–120)
###############################################################################
slack_easy = [
    {
        "id": "slack_001",
        "english": "Hey, quick question about the API endpoint.",
        "context": "Starting a conversation on Slack to ask a teammate something",
        "translations": {
            "pt-BR": "Ei, uma pergunta rápida sobre o endpoint da API.",
            "es": "Oye, una pregunta rápida sobre el endpoint de la API.",
            "fr": "Salut, une question rapide sur l'endpoint de l'API.",
            "de": "Hey, kurze Frage zum API-Endpunkt.",
            "it": "Ehi, una domanda veloce sull'endpoint dell'API.",
            "ja": "APIエンドポイントについて簡単な質問があります。",
            "ko": "API 엔드포인트에 대해 간단한 질문이 있어요.",
            "zh-Hans": "嘿，关于API端点有个快速问题。",
            "hi": "अरे, API एंडपॉइंट के बारे में एक छोटा सा सवाल है।",
            "tr": "Hey, API endpoint'i hakkında kısa bir sorum var."
        },
        "difficulty": "easy",
        "category": "slack"
    },
    {
        "id": "slack_002",
        "english": "Can you take a look at my PR?",
        "context": "Asking a teammate to review your pull request",
        "translations": {
            "pt-BR": "Você pode dar uma olhada no meu PR?",
            "es": "¿Puedes echar un vistazo a mi PR?",
            "fr": "Tu peux jeter un œil à ma PR ?",
            "de": "Kannst du dir meinen PR anschauen?",
            "it": "Puoi dare un'occhiata alla mia PR?",
            "ja": "私のPRを見てもらえますか？",
            "ko": "제 PR 좀 봐주실 수 있나요?",
            "zh-Hans": "你能看一下我的PR吗？",
            "hi": "क्या आप मेरा PR देख सकते हैं?",
            "tr": "PR'ıma bir göz atabilir misin?"
        },
        "difficulty": "easy",
        "category": "slack"
    },
    {
        "id": "slack_003",
        "english": "Sounds good, thanks!",
        "context": "Acknowledging a teammate's response or agreement",
        "translations": {
            "pt-BR": "Parece bom, obrigado!",
            "es": "Suena bien, ¡gracias!",
            "fr": "Ça me va, merci !",
            "de": "Klingt gut, danke!",
            "it": "Mi sembra buono, grazie!",
            "ja": "いいですね、ありがとう！",
            "ko": "좋아요, 감사합니다!",
            "zh-Hans": "听起来不错，谢谢！",
            "hi": "अच्छा लगता है, धन्यवाद!",
            "tr": "Kulağa iyi geliyor, teşekkürler!"
        },
        "difficulty": "easy",
        "category": "slack"
    },
    {
        "id": "slack_004",
        "english": "I'm on it.",
        "context": "Letting someone know you're handling a task",
        "translations": {
            "pt-BR": "Estou cuidando disso.",
            "es": "Estoy en ello.",
            "fr": "Je m'en occupe.",
            "de": "Ich kümmere mich darum.",
            "it": "Me ne occupo io.",
            "ja": "対応中です。",
            "ko": "제가 처리하고 있어요.",
            "zh-Hans": "我在处理了。",
            "hi": "मैं इस पर काम कर रहा हूँ।",
            "tr": "Üzerindeyim."
        },
        "difficulty": "easy",
        "category": "slack"
    },
    {
        "id": "slack_005",
        "english": "Let me check and get back to you.",
        "context": "Telling someone you need time to find an answer",
        "translations": {
            "pt-BR": "Deixa eu verificar e te respondo.",
            "es": "Déjame verificar y te respondo.",
            "fr": "Laisse-moi vérifier et je te reviens.",
            "de": "Lass mich das prüfen und ich melde mich.",
            "it": "Fammi controllare e ti faccio sapere.",
            "ja": "確認して折り返します。",
            "ko": "확인하고 다시 알려드릴게요.",
            "zh-Hans": "我查一下再回复你。",
            "hi": "मैं जाँच करके वापस बताता हूँ।",
            "tr": "Kontrol edip sana döneyim."
        },
        "difficulty": "easy",
        "category": "slack"
    },
    {
        "id": "slack_006",
        "english": "Good morning, team!",
        "context": "Greeting your team at the start of the day in a channel",
        "translations": {
            "pt-BR": "Bom dia, equipe!",
            "es": "¡Buenos días, equipo!",
            "fr": "Bonjour, l'équipe !",
            "de": "Guten Morgen, Team!",
            "it": "Buongiorno, team!",
            "ja": "おはようございます、チームの皆さん！",
            "ko": "좋은 아침이에요, 팀!",
            "zh-Hans": "早上好，团队！",
            "hi": "सुप्रभात, टीम!",
            "tr": "Günaydın, ekip!"
        },
        "difficulty": "easy",
        "category": "slack"
    },
    {
        "id": "slack_007",
        "english": "Is anyone available for a quick sync?",
        "context": "Asking if a teammate can hop on a short call",
        "translations": {
            "pt-BR": "Alguém está disponível para um sync rápido?",
            "es": "¿Alguien está disponible para un sync rápido?",
            "fr": "Quelqu'un est disponible pour un sync rapide ?",
            "de": "Hat jemand Zeit für ein kurzes Sync?",
            "it": "Qualcuno è disponibile per un sync veloce?",
            "ja": "誰か短いミーティングに参加できますか？",
            "ko": "짧은 싱크 미팅 가능한 분 계신가요?",
            "zh-Hans": "有人有空快速同步一下吗？",
            "hi": "क्या कोई एक छोटी सिंक के लिए उपलब्ध है?",
            "tr": "Kısa bir senkronizasyon için müsait olan var mı?"
        },
        "difficulty": "easy",
        "category": "slack"
    },
    {
        "id": "slack_008",
        "english": "Got it, will do.",
        "context": "Confirming you understood a request and will complete it",
        "translations": {
            "pt-BR": "Entendi, farei isso.",
            "es": "Entendido, lo haré.",
            "fr": "Compris, je m'en charge.",
            "de": "Verstanden, mache ich.",
            "it": "Capito, lo farò.",
            "ja": "了解、やります。",
            "ko": "알겠습니다, 할게요.",
            "zh-Hans": "收到，我来做。",
            "hi": "समझ गया, कर दूँगा।",
            "tr": "Anladım, yapacağım."
        },
        "difficulty": "easy",
        "category": "slack"
    },
    {
        "id": "slack_009",
        "english": "The build is broken.",
        "context": "Alerting the team that the CI/CD pipeline is failing",
        "translations": {
            "pt-BR": "O build está quebrado.",
            "es": "El build está roto.",
            "fr": "Le build est cassé.",
            "de": "Der Build ist kaputt.",
            "it": "La build è rotta.",
            "ja": "ビルドが壊れています。",
            "ko": "빌드가 깨졌어요.",
            "zh-Hans": "构建挂了。",
            "hi": "बिल्ड टूट गया है।",
            "tr": "Build bozuldu."
        },
        "difficulty": "easy",
        "category": "slack"
    },
    {
        "id": "slack_010",
        "english": "Thanks for the heads up!",
        "context": "Thanking someone for an early warning about an issue",
        "translations": {
            "pt-BR": "Obrigado pelo aviso!",
            "es": "¡Gracias por el aviso!",
            "fr": "Merci pour l'info !",
            "de": "Danke für den Hinweis!",
            "it": "Grazie per l'avviso!",
            "ja": "教えてくれてありがとう！",
            "ko": "미리 알려줘서 고마워요!",
            "zh-Hans": "谢谢提醒！",
            "hi": "पहले से बताने के लिए धन्यवाद!",
            "tr": "Uyarı için teşekkürler!"
        },
        "difficulty": "easy",
        "category": "slack"
    },
    {
        "id": "slack_011",
        "english": "I just pushed a fix.",
        "context": "Telling the team you committed a bug fix to the repository",
        "translations": {
            "pt-BR": "Acabei de enviar uma correção.",
            "es": "Acabo de subir una corrección.",
            "fr": "Je viens de pousser un correctif.",
            "de": "Ich habe gerade einen Fix gepusht.",
            "it": "Ho appena pushato una correzione.",
            "ja": "修正をプッシュしました。",
            "ko": "방금 수정 사항을 푸시했어요.",
            "zh-Hans": "我刚推了一个修复。",
            "hi": "मैंने अभी एक फिक्स पुश किया।",
            "tr": "Az önce bir düzeltme push'ladım."
        },
        "difficulty": "easy",
        "category": "slack"
    },
    {
        "id": "slack_012",
        "english": "Can you merge this when you get a chance?",
        "context": "Asking someone to merge your approved pull request",
        "translations": {
            "pt-BR": "Você pode fazer o merge quando tiver um momento?",
            "es": "¿Puedes hacer merge cuando puedas?",
            "fr": "Tu peux merger ça quand tu as un moment ?",
            "de": "Kannst du das mergen, wenn du Zeit hast?",
            "it": "Puoi fare il merge quando hai un momento?",
            "ja": "時間があるときにマージしてもらえますか？",
            "ko": "시간 되실 때 머지해 주실 수 있나요?",
            "zh-Hans": "你有空的时候能合并一下吗？",
            "hi": "जब मौका मिले तो इसे मर्ज कर सकते हैं?",
            "tr": "Fırsat bulduğunda bunu merge edebilir misin?"
        },
        "difficulty": "easy",
        "category": "slack"
    },
    {
        "id": "slack_013",
        "english": "I'll be out of office tomorrow.",
        "context": "Notifying the team about your day off",
        "translations": {
            "pt-BR": "Estarei fora do escritório amanhã.",
            "es": "Estaré fuera de la oficina mañana.",
            "fr": "Je serai absent demain.",
            "de": "Ich bin morgen nicht im Büro.",
            "it": "Domani sarò fuori ufficio.",
            "ja": "明日は不在です。",
            "ko": "내일 부재 중이에요.",
            "zh-Hans": "我明天不在。",
            "hi": "मैं कल ऑफिस से बाहर रहूँगा।",
            "tr": "Yarın ofis dışında olacağım."
        },
        "difficulty": "easy",
        "category": "slack"
    },
    {
        "id": "slack_014",
        "english": "Deployed to staging.",
        "context": "Informing the team that code has been deployed to the staging environment",
        "translations": {
            "pt-BR": "Deploy feito no staging.",
            "es": "Desplegado en staging.",
            "fr": "Déployé en staging.",
            "de": "Auf Staging deployt.",
            "it": "Deployato in staging.",
            "ja": "ステージングにデプロイしました。",
            "ko": "스테이징에 배포했어요.",
            "zh-Hans": "已部署到预发布环境。",
            "hi": "स्टेजिंग पर डिप्लॉय कर दिया।",
            "tr": "Staging'e deploy edildi."
        },
        "difficulty": "easy",
        "category": "slack"
    },
    {
        "id": "slack_015",
        "english": "Any blockers?",
        "context": "Asking during standup if anyone has obstacles",
        "translations": {
            "pt-BR": "Algum bloqueio?",
            "es": "¿Algún bloqueante?",
            "fr": "Des blocages ?",
            "de": "Irgendwelche Blocker?",
            "it": "Qualche blocco?",
            "ja": "ブロッカーはありますか？",
            "ko": "블로커 있나요?",
            "zh-Hans": "有什么阻碍吗？",
            "hi": "कोई ब्लॉकर?",
            "tr": "Herhangi bir engel var mı?"
        },
        "difficulty": "easy",
        "category": "slack"
    },
    {
        "id": "slack_016",
        "english": "No blockers on my end.",
        "context": "Reporting that you have no obstacles during standup",
        "translations": {
            "pt-BR": "Sem bloqueios da minha parte.",
            "es": "Sin bloqueantes de mi lado.",
            "fr": "Pas de blocage de mon côté.",
            "de": "Keine Blocker bei mir.",
            "it": "Nessun blocco da parte mia.",
            "ja": "私の方にはブロッカーはありません。",
            "ko": "제 쪽에는 블로커 없어요.",
            "zh-Hans": "我这边没有阻碍。",
            "hi": "मेरी तरफ से कोई ब्लॉकर नहीं।",
            "tr": "Benim tarafımda engel yok."
        },
        "difficulty": "easy",
        "category": "slack"
    },
    {
        "id": "slack_017",
        "english": "I approved your PR.",
        "context": "Letting someone know you reviewed and approved their pull request",
        "translations": {
            "pt-BR": "Aprovei seu PR.",
            "es": "Aprobé tu PR.",
            "fr": "J'ai approuvé ta PR.",
            "de": "Ich habe deinen PR genehmigt.",
            "it": "Ho approvato la tua PR.",
            "ja": "あなたのPRを承認しました。",
            "ko": "PR 승인했어요.",
            "zh-Hans": "我批准了你的PR。",
            "hi": "मैंने आपका PR अप्रूव कर दिया।",
            "tr": "PR'ını onayladım."
        },
        "difficulty": "easy",
        "category": "slack"
    },
    {
        "id": "slack_018",
        "english": "Could you clarify what you mean?",
        "context": "Asking someone to explain their message more clearly",
        "translations": {
            "pt-BR": "Você poderia esclarecer o que quis dizer?",
            "es": "¿Podrías aclarar qué quieres decir?",
            "fr": "Tu pourrais clarifier ce que tu veux dire ?",
            "de": "Könntest du erklären, was du meinst?",
            "it": "Potresti chiarire cosa intendi?",
            "ja": "どういう意味か説明してもらえますか？",
            "ko": "무슨 뜻인지 좀 더 설명해 주실 수 있나요?",
            "zh-Hans": "你能说清楚一点吗？",
            "hi": "क्या आप स्पष्ट कर सकते हैं कि आपका क्या मतलब है?",
            "tr": "Ne demek istediğini açıklayabilir misin?"
        },
        "difficulty": "easy",
        "category": "slack"
    },
    {
        "id": "slack_019",
        "english": "Here's the link to the ticket.",
        "context": "Sharing a Jira or project management ticket link",
        "translations": {
            "pt-BR": "Aqui está o link do ticket.",
            "es": "Aquí está el enlace del ticket.",
            "fr": "Voici le lien du ticket.",
            "de": "Hier ist der Link zum Ticket.",
            "it": "Ecco il link del ticket.",
            "ja": "チケットのリンクはこちらです。",
            "ko": "티켓 링크입니다.",
            "zh-Hans": "这是工单的链接。",
            "hi": "यह रहा टिकट का लिंक।",
            "tr": "İşte ticket'ın linki."
        },
        "difficulty": "easy",
        "category": "slack"
    },
    {
        "id": "slack_020",
        "english": "I left a comment on the PR.",
        "context": "Telling someone you added feedback on their pull request",
        "translations": {
            "pt-BR": "Deixei um comentário no PR.",
            "es": "Dejé un comentario en el PR.",
            "fr": "J'ai laissé un commentaire sur la PR.",
            "de": "Ich habe einen Kommentar zum PR hinterlassen.",
            "it": "Ho lasciato un commento sulla PR.",
            "ja": "PRにコメントを残しました。",
            "ko": "PR에 코멘트 남겼어요.",
            "zh-Hans": "我在PR上留了评论。",
            "hi": "मैंने PR पर एक कमेंट छोड़ा।",
            "tr": "PR'a bir yorum bıraktım."
        },
        "difficulty": "easy",
        "category": "slack"
    },
]

slack_phrases.extend(slack_easy)

print(f"Slack easy batch 1: {len(slack_easy)} phrases (total: {len(slack_phrases)})")
