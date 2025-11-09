
-- 1. users (사용자)
CREATE TABLE users (
    user_id TEXT PRIMARY KEY,                       -- Firebase UID
    email VARCHAR(255) NOT NULL UNIQUE,             -- 이메일 저장
    user_name VARCHAR(100) NOT NULL,                -- 닉네임
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    last_login_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- 2. categories (앱 카테고리)
CREATE TABLE categories (
    category_id SERIAL PRIMARY KEY,
    category_name VARCHAR(50) UNIQUE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- 3. subscriptions (구독 / 앱 정보)
CREATE TABLE subscriptions (
    sub_id SERIAL PRIMARY KEY,
    user_id TEXT NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    app_name VARCHAR(100) NOT NULL,
    category_id INT NOT NULL REFERENCES categories(category_id),
    service_monthly_price NUMERIC(10,2) NOT NULL,
    service_once_price NUMERIC(10,2),
    service_usage_time INTEGER NOT NULL,
    service_usage INTEGER NOT NULL,
    weekly_usage_hours NUMERIC(5,2) NOT NULL,
    user_satis SMALLINT NOT NULL CHECK (user_satis BETWEEN 0 AND 5),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- 4. analysis_result (분석 결과)
CREATE TABLE analysis_result (
    result_id SERIAL PRIMARY KEY,
    sub_id INTEGER NOT NULL REFERENCES subscriptions(sub_id) ON DELETE CASCADE,
    calculated_cph NUMERIC(10,2) NOT NULL,
    quadrant_type VARCHAR(50) NOT NULL,
    last_analyzed_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);
