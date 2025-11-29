from odoo.tests.common import TransactionCase
from odoo.exceptions import ValidationError
import datetime


class TestVisitas(TransactionCase):
    def test_constraint_data_visita_not_past(self):
        partner = self.env['res.partner'].create({'name': 'Test Partner for Visita'})
        # criação com data futura deve funcionar
        future_date = (datetime.datetime.now() + datetime.timedelta(days=1)).strftime('%Y-%m-%d %H:%M:%S')
        visita = self.env['visitas.clientes'].create({
            'name': 'TESTFUT',
            'partner_id': partner.id,
            'data_visita': future_date,
        })
        self.assertEqual(visita.estado, 'draft')

        # criação com data no passado deve falhar (ValidationError)
        past_date = (datetime.datetime.now() - datetime.timedelta(days=1)).strftime('%Y-%m-%d %H:%M:%S')
        with self.assertRaises(ValidationError):
            self.env['visitas.clientes'].create({
                'name': 'TESTPAST',
                'partner_id': partner.id,
                'data_visita': past_date,
            })
