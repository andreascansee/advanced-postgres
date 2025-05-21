\echo '=== 0: Create DB and connect ==='
\i 0_create_db.sql

\echo '=== 1: Create Schema ==='
\i 1_create_schema.sql

\echo '=== 2: Seed Data ==='
\i 2_seed_data.sql

\echo '=== 3: Create App User ==='
\i 3_create_user.sql

\echo '=== 4: Enable RLS ==='
\i 4_enable_rls.sql

\echo '=== 5: Define Policy ==='
\i 5_define_policy.sql

\echo '=== 6: Test RLS Behavior ==='
\i 6_test_rls.sql