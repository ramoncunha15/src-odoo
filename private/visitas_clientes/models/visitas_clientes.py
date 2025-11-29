 #-*- coding: utf-8 -*-
from odoo import models, fields, api, _
from odoo.exceptions import ValidationError

class VisitasClientes(models.Model):
    _name = "visitas.clientes"
    _description = "Visitas aos Clientes"
    _inherit = ["mail.thread", "mail.activity.mixin"]
    _order = "data_visita desc"

    name = fields.Char(string="Referência", default="Nova", readonly=True, copy=False)
    lead_id = fields.Many2one("crm.lead", string="Oportunidade", ondelete="cascade")
    partner_id = fields.Many2one("res.partner", string="Cliente", required=True)
    user_id = fields.Many2one("res.users", string="Responsável", default=lambda self: self.env.user)
    data_visita = fields.Datetime(string="Data da Visita", required=True)
    tipo = fields.Selection([("tecnica", "Técnica"), ("comercial", "Comercial")], string="Tipo", required=True)
    estado = fields.Selection([
        ("draft", "Rascunho"),
        ("confirmada", "Confirmada"),
        ("realizada", "Realizada"),
        ("cancelada", "Cancelada")
    ], string="Estado", default="draft", tracking=True)
    notas = fields.Html(string="Notas")

    @api.model_create_multi
    def create(self, vals_list):
        for vals in vals_list:
            if vals.get("name", "Nova") == "Nova":
                vals["name"] = self.env["ir.sequence"].next_by_code("visitas.clientes") or "Nova"
        return super().create(vals_list)

    def action_confirmar(self):
        self.write({"estado": "confirmada"})

    def action_realizar(self):
        self.write({"estado": "realizada"})

    def action_cancelar(self):
        self.write({"estado": "cancelada"})

    def action_rascunho(self):
        self.write({"estado": "draft"})

    @api.constrains("data_visita")
    def _check_data_visita(self):
        for record in self:
            if record.data_visita < fields.Datetime.now():
                raise ValidationError(_("A data da visita não pode ser no passado."))
