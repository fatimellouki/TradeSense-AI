# LIVRABLES EXAMEN FINAL - PLATEFORME TRADESENSE AI
## Prop Trading Platform - Examen de Projet

---

# 1. INFORMATIONS DE SOUMISSION

## Nom Complet
Fatima Mellouki

## Code Source (GitHub Public)
**Lien:** https://github.com/fatimellouki/TradeSense-AI

**Structure du depot:**
```
/backend
  - app.py (Application Flask principale)
  - models.py (Modeles de base de donnees)
  - requirements.txt (Dependances Python)
  /routes
    - auth.py (Authentification)
    - challenges.py (Gestion challenges)
    - trading.py (Execution trades)
    - payment.py (Paiement Mock + PayPal)
    - leaderboard.py (Classement)
    - admin.py (Panel admin)
  /services
    - challenge_engine.py (Fonction "Killer")
    - market_data.py (yfinance + BVCscrap)
    - ai_signals.py (Signaux IA)

/frontend
  - Application React.js complete
  /src/features
    - dashboard/ (Trading en temps reel)
    - payment/ (Tarification + PayPal)
    - leaderboard/ (Classement)
    - admin/ (Panel admin)
    - auth/ (Login/Register)
```

## Lien de Deploiement Live
- **Frontend (Vercel):** https://tradesenseai.vercel.app
- **Backend (Render):** https://tradesense-ai.onrender.com

## Base de Donnees
**Fichier:** `database.sql` (inclus dans le depot GitHub)

---

# 2. LIVRABLES PAR MODULE

## MODULE A: Le Moteur du "Challenge" (Logique Backend)

### Description
Coeur de la Prop Firm - service Flask qui suit la performance de l'utilisateur.

### Fichiers Implementes
| Fichier | Ligne | Description |
|---------|-------|-------------|
| `backend/services/challenge_engine.py` | 11-195 | Classe ChallengeEngine complete |
| `backend/models.py` | 47-110 | Modele UserChallenge avec PLAN_CONFIG |

### Fonctionnalites Implementees

**1. Solde Virtuel Initial:**
- Starter: 5,000 $
- Pro: 10,000 $
- Elite: 25,000 $

**2. Les Regles (Fonction "Killer"):**

| Regle | Implementation | Fichier:Ligne |
|-------|---------------|---------------|
| Perte Max Journaliere (5%) | `if daily_drawdown >= config['daily_max_loss']` | challenge_engine.py:94-98 |
| Perte Max Totale (10%) | `if total_drawdown >= config['total_max_loss']` | challenge_engine.py:103-107 |
| Objectif Profit (10%) | `if total_profit_pct >= config['profit_target']` | challenge_engine.py:112-116 |

**3. Tache de Fond (Background Task):**
La fonction `evaluate_rules()` est appelee automatiquement apres chaque trade via `trading.py:225`

### Preuve de Fonctionnement
```python
# Extrait de challenge_engine.py:17-30
def evaluate_rules(self, challenge_id):
    """
    The Killer Function - evaluates challenge rules after each trade.

    Rules:
    1. Daily Max Loss: If equity drops 5% in a day -> FAILED
    2. Total Max Loss: If equity drops 10% total -> FAILED
    3. Profit Target: If equity gains 10% -> PASSED
    """
```

---

## MODULE B: Paiement & Acces (Monetisation)

### Description
Simulation du modele de revenu avec Mock Payment et PayPal.

### Fichiers Implementes
| Fichier | Ligne | Description |
|---------|-------|-------------|
| `backend/routes/payment.py` | 1-273 | Routes de paiement completes |
| `frontend/src/features/payment/PricingPage.tsx` | 1-216 | Page tarification |

### Page de Tarification (3 niveaux)
| Plan | Prix | Solde |
|------|------|-------|
| Starter | 200 DH | $5,000 |
| Pro | 500 DH | $10,000 |
| Elite | 1000 DH | $25,000 |

### Simulation de Checkout
1. **Mock Payment (CMI):** Simulation avec spinner + succes automatique
2. **PayPal:** Integration complete avec API sandbox

### Flow du Paiement
```
1. Utilisateur clique "Payer avec CMI/PayPal"
2. Systeme affiche spinner (simulation 2 secondes)
3. Retourne "Succes"
4. Creation dans user_challenges avec status='active'
```

### Configuration PayPal SuperAdmin
- Route: `/api/admin/settings`
- Cles configurables: `paypal_client_id`, `paypal_client_secret`

---

## MODULE C: Le Dashboard Temps Reel (Frontend)

### Description
Tableau de bord professionnel avec donnees REELLES en temps reel.

### Fichiers Implementes
| Fichier | Ligne | Description |
|---------|-------|-------------|
| `backend/services/market_data.py` | 1-274 | Service de donnees marche |
| `frontend/src/features/dashboard/Dashboard.tsx` | - | Dashboard complet |
| `frontend/src/features/dashboard/TradingChart.tsx` | - | Graphiques TradingView |

### Graphiques en Direct
**Librairie:** TradingView Lightweight Charts (gratuite)
```typescript
// TradingChart.tsx:42-64
const chart = createChart(chartContainerRef.current, {
  layout: {
    background: { color: '#0f172a' },
    textColor: '#94a3b8',
  },
  ...
});
```

### Source de Donnees 1 (International)
**Technologie:** yfinance (Python)
```python
# market_data.py:49-82
def get_yfinance_price(self, symbol, market='us'):
    ticker = yf.Ticker(symbol)
    data = ticker.history(period='1d', interval='1m')
```

**Actifs supportes:**
- US: AAPL, TSLA, GOOGL, MSFT, AMZN, META, NVDA
- Crypto: BTC-USD, ETH-USD, SOL-USD, BNB-USD

### Source de Donnees 2 (Maroc)
**Technologie:** BVCscrap (Bourse de Casablanca)
```python
# market_data.py:84-123
def get_morocco_price(self, symbol):
    from BVCscrap import LoadData
    data = LoadData(symbol, start_date, end_date)
```

**Actifs marocains:**
- IAM (Maroc Telecom)
- ATW (Attijariwafa Bank)
- BCP, CIH, LHM, MNG

### Mise a Jour Temps Reel
- Intervalle: 10-60 secondes
- Sans rafraichissement de page
- Endpoint: `/api/trading/market-data/<symbol>`

### Panneau de Signaux IA
- Signaux: Achat / Vente / Hold
- Confiance: 0-100%
- Raisonnement explicatif
- Fichier: `backend/services/ai_signals.py`

### Execution des Trades
- Boutons "Acheter" / "Vendre"
- Prix reel actuel
- Endpoint: `/api/trading/execute`

---

## MODULE D: Le Classement (Gamification)

### Description
Leaderboard public pour stimuler l'engagement.

### Fichiers Implementes
| Fichier | Ligne | Description |
|---------|-------|-------------|
| `backend/routes/leaderboard.py` | 1-131 | API Leaderboard |
| `frontend/src/features/leaderboard/LeaderboardPage.tsx` | - | Page classement |

### Leaderboard Public
- Affiche "Top 10 Traders du Mois"
- Trie par % de Profit
- Mise a jour en temps reel

### Requete SQL
```sql
SELECT
    u.username,
    uc.plan_type,
    ((uc.equity - uc.initial_balance) / uc.initial_balance * 100) as profit_percent,
    COUNT(t.id) as total_trades
FROM users u
JOIN user_challenges uc ON u.id = uc.user_id
LEFT JOIN trades t ON uc.id = t.challenge_id
WHERE uc.status IN ('active', 'passed')
GROUP BY u.id, uc.id
ORDER BY profit_percent DESC
LIMIT 10;
```

---

# 3. POINTS BONUS IMPLEMENTES

| Feature | Status | Description |
|---------|--------|-------------|
| Localisation FR/AR/EN | FAIT | Bouton de changement de langue dans navbar |
| Dark Mode | FAIT | Toggle mode sombre (defaut: active) |
| Panel Admin | FAIT | Route /admin pour gestion utilisateurs |
| Panel SuperAdmin | FAIT | Configuration PayPal + promotion admin |

---

# 4. SCHEMA DE BASE DE DONNEES

**Fichier:** `database.sql`

### Tables
1. **users** - Utilisateurs et authentification
2. **user_challenges** - Challenges de trading (coeur de la prop firm)
3. **trades** - Historique des trades
4. **positions** - Positions ouvertes
5. **market_data** - Cache des donnees de marche
6. **ai_signals** - Signaux IA generes
7. **admin_settings** - Configuration admin (PayPal, etc.)

---

# 5. SCRIPT VIDEO DEMO (3-5 MINUTES)

## MINUTE 1: Landing Page & Achat Challenge

### Scene 1.1 - Landing Page (0:00 - 0:30)
**Action:** Ouvrir https://tradesenseai.vercel.app

**Narration:**
> "Bonjour, je vous presente TradeSense AI, la premiere plateforme de Prop Trading assistee par Intelligence Artificielle pour l'Afrique.
>
> TradeSense AI combine des analyses IA en temps reel, des outils de trading intelligents, et des donnees de marche en direct.
>
> La plateforme propose des signaux Achat/Vente/Stop, des plans de trade personnalises, et des alertes de detection de risque."

**Elements a montrer:**
- Logo et titre "TradeSense AI"
- Section hero avec texte marketing
- Boutons de navigation

### Scene 1.2 - Page Tarification (0:30 - 1:00)
**Action:** Cliquer sur "Tarifs" dans la navbar

**Narration:**
> "Voici notre page de tarification avec trois niveaux de challenges:
> - Starter a 200 dirhams avec un solde de 5000 dollars
> - Pro a 500 dirhams avec 10000 dollars
> - Elite a 1000 dirhams avec 25000 dollars
>
> Je vais selectionner le plan Starter et proceder au paiement simule."

**Actions a effectuer:**
1. Cliquer sur le plan "Starter"
2. Selectionner "CMI / Demo" comme methode de paiement
3. Cliquer sur "Payer 200 DH"
4. Montrer le spinner de chargement
5. Observer la redirection vers le dashboard

---

## MINUTE 2: Dashboard & Donnees Temps Reel

### Scene 2.1 - Dashboard Principal (1:00 - 1:30)
**Action:** Observer le dashboard

**Narration:**
> "Voici le dashboard de trading. En haut, vous voyez mon solde actuel, mon equite, et mon P&L total.
>
> Les regles du challenge sont affichees:
> - Perte max journaliere: 5%
> - Perte max totale: 10%
> - Objectif de profit: 10%"

**Elements a montrer:**
- Solde: $5,000
- Equite: $5,000
- Statut: EN COURS
- Regles du challenge

### Scene 2.2 - Donnees Marche US (1:30 - 1:50)
**Action:** Cliquer sur AAPL puis BTC

**Narration:**
> "Je clique sur AAPL - Apple. Le graphique se charge avec les donnees REELLES de Yahoo Finance via yfinance.
>
> Maintenant je passe sur BTC - Bitcoin. Observez que le prix se met a jour automatiquement toutes les 30 secondes sans rafraichir la page."

**IMPORTANT:** Attendre 30 secondes pour montrer la mise a jour automatique

### Scene 2.3 - Donnees Marche Maroc (1:50 - 2:10)
**Action:** Cliquer sur IAM (Maroc Telecom)

**Narration:**
> "Et voici les donnees de la Bourse de Casablanca. Je clique sur IAM - Maroc Telecom.
>
> Ces donnees sont recuperees via BVCscrap, une librairie Python qui scrape les prix depuis la Bourse de Casablanca.
>
> Vous pouvez voir le prix actuel et le pourcentage de variation."

**Elements a montrer:**
- Prix IAM en dirhams
- Graphique historique
- Indicateur de variation

---

## MINUTE 3: Demonstration Logique d'Echec

### Scene 3.1 - Preparation (2:10 - 2:30)
**Action:** Selectionner un actif volatile (BTC)

**Narration:**
> "Maintenant je vais demonstrer la logique d'echec - la fonction 'Killer' de notre Prop Firm.
>
> Mon solde initial est de 5000 dollars. Si je perds plus de 10% soit 500 dollars, mon compte sera automatiquement marque comme ECHEC."

### Scene 3.2 - Execution de Trades Perdants (2:30 - 3:20)
**Action:** Executer plusieurs trades pour perdre de l'argent

**Narration:**
> "Je vais acheter du Bitcoin avec une grande quantite, puis le revendre immediatement a perte pour simuler des pertes.
>
> Observez comment le solde diminue apres chaque trade. Le systeme calcule automatiquement le drawdown."

**Actions:**
1. Acheter BTC (quantite elevee)
2. Vendre immediatement
3. Repeter jusqu'a atteindre -10%

### Scene 3.3 - Compte Echec (3:20 - 3:40)
**Action:** Observer le changement de statut

**Narration:**
> "Et voila! Le statut est passe de 'EN COURS' a 'ECHEC' automatiquement.
>
> La fonction Killer a detecte que ma perte totale a depasse 10% et a desactive mon challenge.
>
> C'est exactement comme ca que fonctionne une vraie Prop Firm."

---

## MINUTE 4: Structure du Code & Scraper Maroc

### Scene 4.1 - Structure Backend (3:40 - 4:10)
**Action:** Montrer VS Code ou GitHub

**Narration:**
> "Voici la structure du code. Le backend est en Python Flask avec les fichiers suivants:
>
> - app.py: Application principale avec CORS et JWT
> - models.py: Les modeles de base de donnees
> - services/challenge_engine.py: La fonction Killer
> - services/market_data.py: Integration yfinance et BVCscrap"

### Scene 4.2 - Scraper Maroc (4:10 - 4:40)
**Action:** Ouvrir market_data.py

**Narration:**
> "Pour les donnees marocaines, j'ai utilise l'IA pour generer ce scraper.
>
> Mon prompt etait: 'Ecris un script Python utilisant BVCscrap pour recuperer le prix actuel de l'action Maroc Telecom.'
>
> L'IA a genere cette fonction get_morocco_price qui utilise LoadData de BVCscrap pour scraper les prix depuis la Bourse de Casablanca."

**Code a montrer:**
```python
def get_morocco_price(self, symbol):
    from BVCscrap import LoadData
    data = LoadData(symbol, start_date, end_date)
```

### Scene 4.3 - Conclusion (4:40 - 5:00)
**Narration:**
> "En resume, TradeSense AI est une plateforme complete de Prop Trading qui integre:
> - Un moteur de challenge avec fonction Killer
> - Des donnees temps reel US, Crypto, et Maroc
> - Des signaux IA
> - Un systeme de paiement
> - Et un classement gamifie
>
> Merci pour votre attention."

---

# 6. CHECKLIST FINALE

- [x] Code Source sur GitHub Public
- [x] /backend avec Flask (app.py, models.py, requirements.txt)
- [x] /frontend avec React
- [x] Deploiement Live (Vercel + Render)
- [x] Fichier database.sql
- [x] Module A: Moteur Challenge avec Fonction Killer
- [x] Module B: Paiement Mock + PayPal
- [x] Module C: Dashboard Temps Reel
- [x] Module D: Leaderboard Top 10
- [x] BONUS: Localisation FR/AR/EN
- [x] BONUS: Dark Mode
- [x] BONUS: Panel Admin/SuperAdmin

---

# 7. LIENS DE SOUMISSION

| Element | Lien |
|---------|------|
| GitHub | https://github.com/fatimellouki/TradeSense-AI |
| Frontend Live | https://tradesenseai.vercel.app |
| Backend API | https://tradesense-ai.onrender.com |
| Video Demo | [A AJOUTER APRES ENREGISTREMENT] |

---

**Document genere automatiquement - TradeSense AI Exam Submission**
