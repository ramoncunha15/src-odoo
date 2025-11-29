{
    "name": "Visitas aos Clientes",
    "summary": "Gestão de visitas técnicas/comerciais aos clientes",
    "version": "18.0.1.0.0",
    "category": "CRM",
    "author": "Aluno CINEL - Ramon Cunha",
    "license": "LGPL-3",
    "depends": ["crm", "base"],
    "data": [
        "security/visitas_clientes_groups.xml",
        "security/ir.model.access.csv",
        "views/visitas_clientes_views.xml",
        "data/visitas_clientes_data.xml",
    ],
    "demo": [
        "demo/visitas_demo.xml",
    ],
    "installable": True,
    "auto_install": False,
}
