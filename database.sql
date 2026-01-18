-- ============================================
-- TradeSense AI - Schema de Base de Donnees
-- Plateforme de Prop Trading avec IA
-- ============================================

-- Table: users (Utilisateurs)
CREATE TABLE IF NOT EXISTS users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    email VARCHAR(255) NOT NULL UNIQUE,
    username VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(20) DEFAULT 'user',  -- user, admin, superadmin
    language VARCHAR(5) DEFAULT 'fr',  -- fr, ar, en
    dark_mode BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_username ON users(username);

-- Table: user_challenges (Challenges de Trading - Coeur de la Prop Firm)
CREATE TABLE IF NOT EXISTS user_challenges (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL REFERENCES users(id),
    plan_type VARCHAR(20) NOT NULL,  -- starter, pro, elite
    initial_balance DECIMAL(12,2) NOT NULL,
    current_balance DECIMAL(12,2) NOT NULL,
    equity DECIMAL(12,2) NOT NULL,
    daily_pnl DECIMAL(12,2) DEFAULT 0,
    total_pnl DECIMAL(12,2) DEFAULT 0,
    daily_high_equity DECIMAL(12,2),  -- Pour calcul drawdown journalier
    status VARCHAR(20) DEFAULT 'active',  -- active, passed, failed
    payment_method VARCHAR(50),
    payment_reference VARCHAR(255),
    start_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    end_date TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_challenges_user ON user_challenges(user_id);
CREATE INDEX idx_challenges_status ON user_challenges(status);

-- Table: trades (Historique des Trades)
CREATE TABLE IF NOT EXISTS trades (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL REFERENCES users(id),
    challenge_id INTEGER NOT NULL REFERENCES user_challenges(id),
    symbol VARCHAR(20) NOT NULL,
    market VARCHAR(20) NOT NULL,  -- us, morocco, crypto
    side VARCHAR(10) NOT NULL,  -- buy, sell
    quantity DECIMAL(18,8) NOT NULL,
    entry_price DECIMAL(18,8) NOT NULL,
    exit_price DECIMAL(18,8),
    profit DECIMAL(12,2),
    status VARCHAR(20) DEFAULT 'open',  -- open, closed
    executed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    closed_at TIMESTAMP
);
CREATE INDEX idx_trades_user ON trades(user_id);
CREATE INDEX idx_trades_challenge ON trades(challenge_id);

-- Table: positions (Positions Ouvertes)
CREATE TABLE IF NOT EXISTS positions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL REFERENCES users(id),
    challenge_id INTEGER NOT NULL REFERENCES user_challenges(id),
    symbol VARCHAR(20) NOT NULL,
    market VARCHAR(20) NOT NULL,
    side VARCHAR(10) NOT NULL,  -- long, short
    quantity DECIMAL(18,8) NOT NULL,
    entry_price DECIMAL(18,8) NOT NULL,
    current_price DECIMAL(18,8),
    unrealized_pnl DECIMAL(12,2),
    opened_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_positions_challenge ON positions(challenge_id);

-- Table: market_data (Donnees de Marche en Cache)
CREATE TABLE IF NOT EXISTS market_data (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    symbol VARCHAR(20) NOT NULL UNIQUE,
    market VARCHAR(20) NOT NULL,  -- us, morocco, crypto
    price DECIMAL(18,8) NOT NULL,
    open_price DECIMAL(18,8),
    high_price DECIMAL(18,8),
    low_price DECIMAL(18,8),
    change_percent DECIMAL(8,4),
    volume DECIMAL(20,2),
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_market_symbol ON market_data(symbol);

-- Table: ai_signals (Signaux IA)
CREATE TABLE IF NOT EXISTS ai_signals (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    symbol VARCHAR(20) NOT NULL,
    market VARCHAR(20) NOT NULL,
    signal_type VARCHAR(10) NOT NULL,  -- buy, sell, hold
    confidence DECIMAL(5,2),
    reasoning TEXT,
    generated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP
);
CREATE INDEX idx_signals_symbol ON ai_signals(symbol);

-- Table: admin_settings (Configuration Admin - PayPal, etc.)
CREATE TABLE IF NOT EXISTS admin_settings (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    key VARCHAR(100) NOT NULL UNIQUE,
    value TEXT,
    category VARCHAR(50),
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- REGLES DU CHALLENGE (FONCTION "KILLER")
-- ============================================
-- Configuration par plan (stockee dans le code):
--
-- STARTER (200 DH):
--   - Solde initial: 5,000 $
--   - Perte max journaliere: 5%
--   - Perte max totale: 10%
--   - Objectif profit: 10%
--
-- PRO (500 DH):
--   - Solde initial: 10,000 $
--   - Perte max journaliere: 5%
--   - Perte max totale: 10%
--   - Objectif profit: 10%
--
-- ELITE (1000 DH):
--   - Solde initial: 25,000 $
--   - Perte max journaliere: 5%
--   - Perte max totale: 10%
--   - Objectif profit: 10%
-- ============================================

-- ============================================
-- REQUETE LEADERBOARD (TOP 10)
-- ============================================
-- SELECT
--     u.username,
--     uc.plan_type,
--     uc.initial_balance,
--     uc.equity,
--     ((uc.equity - uc.initial_balance) / uc.initial_balance * 100) as profit_percent,
--     COUNT(t.id) as total_trades
-- FROM users u
-- JOIN user_challenges uc ON u.id = uc.user_id
-- LEFT JOIN trades t ON uc.id = t.challenge_id
-- WHERE uc.status IN ('active', 'passed')
-- GROUP BY u.id, uc.id
-- ORDER BY profit_percent DESC
-- LIMIT 10;
-- ============================================
