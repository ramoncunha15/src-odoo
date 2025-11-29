# Atualização para viabilizar PR
# Nenhuma alteração funcional.

# Addons privados — `visitas_clientes`

Idioma: Português (Portugal)

Este diretório contém os addons privados do projecto Odoo embutido neste ambiente de desenvolvimento. O foco principal é o módulo `visitas_clientes`, que gere visitas técnicas/comerciais aos clientes.

Sumário
- Visão geral
- Estrutura do módulo
- Como instalar / atualizar
- Testes e dados de demonstração
- Diagrama de rede lógico (ASCII)
- Interações principais com o ecossistema Odoo e com a BD
- Boas práticas de desenvolvimento
- Licenciamento

Visão geral
--------------
O módulo `visitas_clientes` fornece um modelo simples para registar visitas a clientes, com estados (rascunho, confirmada, realizada, cancelada), integração com `res.partner`, ligação opcional a `crm.lead` e utiliza `ir.sequence` para referências.

Objectivos principais
- Registo e gestão de visitas
- Relacionamento com clientes e oportunidades CRM
- Visualização em lista e formulário com uma `statusbar`
- Dados demo para onboarding rápido
- Testes unitários básicos para validar restrições de dados

Estrutura do módulo (exemplo)
--------------------------------
private/
  └─ visitas_clientes/
     ├─ __manifest__.py
     ├─ models/
     │  └─ visitas_clientes.py
     ├─ views/
     │  └─ visitas_clientes_views.xml
     ├─ security/
     │  ├─ ir.model.access.csv
     │  └─ visitas_clientes_groups.xml
     ├─ data/
     │  └─ visitas_clientes_data.xml
     ├─ demo/
     │  └─ visitas_demo.xml
     └─ tests/
        ├─ __init__.py
        └─ test_visitas.py

Como instalar / atualizar o módulo (docker-compose)
--------------------------------------------------
No ambiente deste projecto (doodba / docker-compose), usar:

```bash
cd /opt/odoo/crm/develop
# Atualizar o módulo no container Odoo (DB: devel)
docker compose -f devel.yaml exec -T odoo \
  odoo -c /opt/odoo/auto/odoo.conf -d devel -u visitas_clientes --stop-after-init
```

Para forçar a reconstrução das assets web (se necessário):

```bash
docker compose -f devel.yaml exec -T odoo \
  odoo -c /opt/odoo/auto/odoo.conf -d devel -u web --stop-after-init
```

Executar os testes do módulo (modo rápido)
-----------------------------------------
É possível executar os testes isoladamente num processo do Odoo (usando porta 0 para evitar conflitos):

```bash
docker compose -f devel.yaml exec -T odoo \
  odoo -d devel -i visitas_clientes --test-enable --stop-after-init --http-port=0
```

Se os testes não forem detectados automaticamente, certifique-se que existe `tests/__init__.py` para tornar o directório um pacote Python.

Dados de demonstração
---------------------
O módulo inclui um ficheiro `demo/visitas_demo.xml` que cria um partner de demonstração e uma visita de exemplo. Utilize-o para navegar rapidamente pela interface depois de instalar o módulo.

Diagrama de rede lógico (ASCII)
--------------------------------
Explicação: o diagrama abaixo mostra como o pedido HTTP do browser percorre o ecossistema até ao módulo `visitas_clientes` e à base de dados.

Browser (cliente)
   |
   |  (1) HTTPS/HTTP request
   v
Reverse Proxy / Cloudflare (opcional)
   |
   |  (2) encaminha para host:porta (ex. 127.0.0.1:18069)
   v
Host / NGINX (proxy local)
   |
   |  (3) proxy -> container Odoo:8069
   v
Odoo (container) — `web` addon
   |
   |  (4) Router `/web/*` (assets, controllers)
   |  (5) QWeb templates (login, webclient)
   v
Addon `visitas_clientes` (módulo privado)
   |
   |  (6) ORM -> modelos: `visitas.clientes`, relacionamentos com `res.partner`, `crm.lead`, `res.users`
   v
PostgreSQL (DB)

Resumo das etapas de interação
- O browser carrega `/web/login` -> Odoo serve a template e os bundles JS/CSS (web.assets_*).
- Ao criar/editar uma visita, o front-end envia request para `/web/dataset/call_kw/visitas.clientes/...` ou submete formulário tradicional.
- O controlador Odoo invoca a lógica do modelo (métodos `create`, constraints) que interage com a BD.

Dependências internas
- `crm` (opcional para `lead_id`)
- `base` (res.partner, ir.sequence, segurança)

Segurança e permissões
----------------------
- O ficheiro `security/ir.model.access.csv` define o acesso básico (normalmente `base.group_user` com leitura/escrita).
- Para produção, reveja cuidadosamente as regras de acesso e considere separar grupos (por exemplo: `visitas_manager`, `visitas_user`).

Boas práticas de desenvolvimento
--------------------------------
- Use uma base de desenvolvimento separada (ex.: `devel`) para atualizar modules.
- Evite editar ficheiros gerados automaticamente em `/opt/odoo/auto` — em vez disso altere os ficheiros fonte em `custom/src`.
- Commit das alterações no `private` deve incluir manifest, views, tests e demo.
- Reverter hacks temporários (ex.: remover `d-none` manual no template de login) assim que as assets estejam a funcionar.

Contribuição e fluxo local de trabalho
-------------------------------------
1. Criar branch local: `git checkout -b feat/visitas-xxx`
2. Fazer alterações nos ficheiros em `odoo/custom/src/private/visitas_clientes`
3. Atualizar módulo e testar no container (ver comandos acima)
4. Executar testes e validar
5. Submeter PR para revisão

Licença
-------
O módulo é licenciado sob a GNU Lesser General Public License v3.0 (LGPL-3). Consulte o ficheiro `LICENSE` neste diretório para o texto completo.

Contacto
--------
Autor / Maintainer: Ramon Cunha
E-mail: (ver configuração do projecto)

Notas finais
------------
Este `README.md` documenta a configuração mínima para desenvolvimento e integração do módulo `visitas_clientes` no ambiente doodba/container fornecido. Se houver necessidade, posso adicionar instruções para integração CI, scripts de criação de DB de teste e exemplos de CURL para endpoints específicos.
