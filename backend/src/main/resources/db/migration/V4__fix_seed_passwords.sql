-- V4__fix_seed_passwords.sql
-- Ensure all seeded accounts use a valid BCrypt hash for password '123456'
UPDATE users
SET password_hash = '$2a$10$7UaGr9L103mddt491POF9.vK5IOHJniyeYoO1RWwDUvBPxtMlE9Pq'
WHERE password_hash = '$2a$10$8.UnVuG9HHgffUDAlk8qfOuVGkqRzgVymGe07xd00DMxs.AQubh4a';
