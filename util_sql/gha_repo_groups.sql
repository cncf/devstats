CREATE TABLE public.gha_repo_groups (
    id bigint NOT NULL,
    name character varying(160) NOT NULL,
    repo_group character varying(80),
    org_id bigint,
    org_login character varying(100),
    alias character varying(160)
);
ALTER TABLE public.gha_repo_groups OWNER TO gha_admin;
ALTER TABLE ONLY public.gha_repo_groups ADD CONSTRAINT gha_repo_groups_pkey PRIMARY KEY (id, name, repo_group);
CREATE INDEX repo_groups_alias_idx ON public.gha_repo_groups USING btree (alias);
CREATE INDEX repo_groups_id_idx ON public.gha_repo_groups USING btree (id);
CREATE INDEX repo_groups_name_idx ON public.gha_repo_groups USING btree (name);
CREATE INDEX repo_groups_org_id_idx ON public.gha_repo_groups USING btree (org_id);
CREATE INDEX repo_groups_org_login_idx ON public.gha_repo_groups USING btree (org_login);
CREATE INDEX repo_groups_repo_group_idx ON public.gha_repo_groups USING btree (repo_group);
