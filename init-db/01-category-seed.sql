-- 카테고리 초기 데이터 삽입
-- PostgreSQL이 처음 초기화될 때만 실행됩니다 (데이터가 이미 있으면 실행되지 않음)
INSERT INTO categories (category_name) VALUES 
('OTT'),
('Music'),
('Contents'),
('AI'),
('LifeStyle')
ON CONFLICT (category_name) DO NOTHING;
