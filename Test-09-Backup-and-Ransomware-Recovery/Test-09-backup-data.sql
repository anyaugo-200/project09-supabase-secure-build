SET session_replication_role = replica;

--
-- PostgreSQL database dump
--

-- \restrict TuFnFQN4TFDRl5QWuAmIPczbPPbtL69legM68jftOPvWGthimZbkl8pTwfqpbZo

-- Dumped from database version 17.11
-- Dumped by pg_dump version 17.11

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Data for Name: accounts; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."accounts" ("id", "owner_id", "account_name", "balance_cents", "created_at") VALUES
	('feb7c541-bc39-40e9-9d34-d9e6c804d68a', '02503f0b-1940-4dfa-830f-7ec0039a482b', 'Alice Current', 1500000, '2026-10-09 03:02:26.815223+00'),
	('08a3b945-763f-4a94-854e-1bb5cb4a4352', 'd1c32024-abf8-4575-9f77-b8c01217926b', 'Bob Savings', 9900000, '2026-10-09 03:02:26.815223+00');


--
-- Data for Name: profiles; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."profiles" ("id", "full_name", "created_at") VALUES
	('02503f0b-1940-4dfa-830f-7ec0039a482b', 'Alice Tester', '2026-10-09 03:02:26.815223+00'),
	('d1c32024-abf8-4575-9f77-b8c01217926b', 'Bob Tester', '2026-10-09 03:02:26.815223+00');


--
-- Data for Name: transactions; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."transactions" ("id", "account_id", "amount_cents", "description", "created_at") VALUES
	('5d5f1477-8a3b-468d-b4fc-f03509e5170a', 'feb7c541-bc39-40e9-9d34-d9e6c804d68a', -2500, 'Coffee', '2026-10-09 03:02:26.815223+00'),
	('1a597051-da76-4197-a970-4294507c2260', 'feb7c541-bc39-40e9-9d34-d9e6c804d68a', 500000, 'Salary', '2026-10-09 03:02:26.815223+00'),
	('090c99f5-4747-44c9-8d51-0673afc7ee85', '08a3b945-763f-4a94-854e-1bb5cb4a4352', -1000, 'Snack', '2026-10-09 03:02:26.815223+00'),
	('d219a25d-9848-4ba0-b620-e5b135fa74ab', '08a3b945-763f-4a94-854e-1bb5cb4a4352', 750000, 'Bonus', '2026-10-09 03:02:26.815223+00');


--
-- PostgreSQL database dump complete
--

-- \unrestrict TuFnFQN4TFDRl5QWuAmIPczbPPbtL69legM68jftOPvWGthimZbkl8pTwfqpbZo

RESET ALL;
