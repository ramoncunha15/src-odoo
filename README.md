README
======

Resumo rápido
-------------
Este diretório (`odoo/custom/src`) contém a configuração local dos addons e dos
repositórios privados usados pelo projeto doodba local. Aqui estão as instruções
para localizar, atualizar e sincronizar os módulos privados (ex.: `visitas_clientes`).

Localização dos módulos privados
--------------------------------
- Repositórios a clonar/gerir: `repos.yaml` (bloco `./private`).
- Addons privados clonados ficam em: `./private` (ex.: `./private/visitas_clientes`).
- Arquivos de configuração principais: `repos.yaml`, `addons.yaml`, `.gitignore`.

Fluxo de atualização (resumido)
------------------------------
1. Desenvolva localmente no teu fork/repositório remoto (`git@github.com:ramoncunha15/src-odoo.git`).
2. Faça push das alterações para `main` (ou a branch que usas no repositório privado).
3. No servidor/projeto local (este diretório), rode o script de sincronização para trazer
   os arquivos do teu repositório para `src`.

Scripts úteis (local)
---------------------
- `scripts/clone_from_repos_yaml.sh` — atualiza/clone o repositório configurado em `repos.yaml`.
  - Uso (dry-run):

    ```bash
    ./scripts/clone_from_repos_yaml.sh
    ```

  - Aplicar alterações (faz checkout/pull no `./private`):

    ```bash
    ./scripts/clone_from_repos_yaml.sh --yes
    ```

- `scripts/sync_template_and_replace.sh` — sincroniza um template oficial doodba e substitui
  as partes configuradas pelo teu repositório (dry-run por padrão).
  - Ver o que seria feito (simulação):

    ```bash
    ./scripts/sync_template_and_replace.sh
    ```

  - Aplicar (cuidado — faz backup e substitui):

    ```bash
    ./scripts/sync_template_and_replace.sh --yes
    ```

Backups e segurança
-------------------
- Ambos os scripts fazem backups antes de sobrescrever:
  - `clone_from_repos_yaml.sh` não sobrescreve sem tentar preservar o que já existe; caso haja
    ficheiros desmonitorizados, ele aborta para evitar perda.
  - `sync_template_and_replace.sh` cria backups em `backup_sync_<timestamp>/` antes de mover/os substituir.

Cuidado
-------
- Substituir `private/` pela versão do teu repositório irá sobrescrever alterações locais não comitadas.
  Garanta que tens cópias ou que as alterações locais estão cometidas antes de aplicar.

Como testar rapidamente
-----------------------
1. No diretório `odoo/custom/src` rode os scripts em modo simulação para validar:

   ```bash
   ./scripts/clone_from_repos_yaml.sh
   ./scripts/sync_template_and_replace.sh
   ```

2. Se tudo estiver conforme, aplique com `--yes` no segundo script (ou no primeiro para efetivar o clone).

Ajuda / Contacto
----------------
Se precisares, posso executar estes passos por ti (aplicar os `--yes`) ou adaptar os scripts
para excluir/ incluir itens específicos. Diz se queres que eu aplique as mudanças agora.
