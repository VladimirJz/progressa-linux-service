from decimal import Decimal
class Repository():
    Integracion=[
       {'routine':'PGS_MAESTROSALDOS',
        'keyword':'saldos_diarios',
        'output':'table',
       'parameters':
                    [{  'order':'1',
                        'name':'Tipo',
                        'type':str,
                        'default':'G',# Global
                        'required':False 
                    },
                     {'order':'2',
                     'name':'Instrumento',
                     'type':str,
                      'default':"",
                     'required':False 
                    },
                    {'order':'3',
                     'name':'OrigenID',
                     'type':'int',
                      'default':0,
                     'required':False
                    },
                                        
                    {'order':'4',
                     'name':'Consolidado',# Option
                     'type':str,
                     'default':'N', 
                     'required':False 
                    },

                    ]
       },
       {'routine':'PGS_MAESTROSALDOS',
        'keyword':'saldos_actualizados',
        'output':'table',
       'parameters':
                    [{  'order':'1',
                        'name':'Tipo',
                        'type':str,
                        'default':'I',# Por Intrumento Credito/Cliente
                        'required':False 
                    },
                     {'order':'2',
                     'name':'Instrumento',
                     'type':str,
                      'default':"T",
                     'required':False 
                    },
                    {'order':'3',
                     'name':'UltimaTransaccion',#OrigenID
                     'type':'int',
                      'default':0,
                     'required':True
                    },
                                        
                    {'order':'4',
                     'name':'S',# Option
                     'type':str,
                     'default':'N', 
                     'required':False 
                    },

                    ]
       },
    ]
    
    Cartera =[
            {'routine':'PGSVENCIMIENTOSREP',
            'keyword':'vencimientos',
            'output':'table',
            'parameters':
                        [{  'order':1,
                            'name':'FechaInicio',
                            'type': str,
                            'default':'1900-01-01',# Global
                            'required':True 
                        },
                        {  'order':2,
                            'name':'FechaFin',
                            'type':str,
                            'default':'1900-01-01',# Global
                            'required':True 
                        },
                        {  'order': 3,
                            'name':'SucursalID',
                            'type':int,
                            'default':0,# Global
                            'required':False 
                        },
                        {  'order': 4,
                            'name':'Moneda',
                            'type':int,
                            'default':0,# Global
                            'required':False 
                        },
                        {  'order': 5,
                            'name':'ProductoID',
                            'type':int,
                            'default':0,# Global
                            'required':False 
                        },
                        {  'order':6,
                            'name':'PromotorID',
                            'type':int,
                            'default':0,# Global
                            'required':False 
                        },
                        {  'order':7,
                            'name':'Genero',
                            'type':str,
                            'default':"",# Global
                            'required':False 
                        },
                        {  'order':8,
                            'name':'EstadoID',
                            'type':int,
                            'default':0,# Global
                            'required':False 
                        },
                        {  'order':9,
                            'name':'MunicipioID',
                            'type':int,
                            'default':0,# Global
                            'required':False 
                        },
                        {  'order':10,
                            'name':'MinDiasAtraso',
                            'type':int,
                            'default':0,# Global
                            'required':False 
                        },
                        {  'order':11,
                            'name':'MaxDiasAtraso',
                            'type':int,
                            'default':99999,# Global
                            'required':False 
                        },
                        {  'order':12,
                            'name':'InstNominaID',
                            'type':int,
                            'default':0,# Global
                            'required':False 
                        },
                        {  'order':13,
                            'name':'ConvenioID',
                            'type':int,
                            'default':0,# Global
                            'required':False 
                        },
                        {  'order':14,
                            'name':'EmpresaID',
                            'type':int,
                            'default':1,# Global
                            'required':False 
                        },
                        {  'order':15,
                            'name':'Usuario',
                            'type':int,
                            'default':1,# Global
                            'required':False 
                        },

                      {  'order':16,
                            'name':'FechaActual',
                            'type':str,
                            'default':'1900-01-01',# Global
                            'required':False 
                        },
                      {  'order':17,
                            'name':'DireccionIP',
                            'type':str,
                            'default':'127.0.01',# Global
                            'required':False 
                        },

                      {  'order':18,
                            'name':'ProgramaID',
                            'type':str,
                            'default':1,# Global
                            'required':False 
                        },

                      {  'order':19,
                            'name':'Sucursal',
                            'type':int,
                            'default':1,# Global
                            'required':False 
                        },                   
                        {  'order':20,
                            'name':'Transaccion',
                            'type':int,
                            'default':1,# Global
                            'required':False 
                        },
                        
                        ]
            }
            ]
    Bulk =[
            {'routine':'PAGOCREDITOPRO',
            'keyword':'pago-credito',
            'output':'table',
            'parameters':
                        [{  'order':1,
                            'name':'CreditoID',
                            'type': int,
                            'default':0,
                            'required':True 
                        },
                        {  'order':2,
                            'name':'CuentaID',
                            'type':int,
                            'default':0,
                            'required':True 
                        },
                        {  'order': 3,
                            'name':'MontoPagar',
                            'type':Decimal,
                            'default':0,
                            'required':True 
                        },
                        {  'order': 4,
                            'name':'MonedaID',
                            'type':int,
                            'default':1,# Pesos Mexicanos
                            'required':False 
                        },
                        {  'order': 5,
                            'name':'EsPrepago',
                            'type':str,
                            'default':'N',# No es prepago
                            'required':False 
                        },
                        {  'order':6,
                            'name':'EsFiniquito',
                            'type':str,
                            'default':'N',# No es finiquito
                            'required':False 
                        },
                        {  'order':7,
                            'name':'EmpresaID',
                            'type':int,
                            'default':1,# Empresa predeterminada
                            'required':False 
                        },
                        {  'order':8,
                            'name':'Salida',
                            'type':str,
                            'default':'S',# Global
                            'required':False 
                        },
                        {  'order':9,
                            'name':'MaestroPoliza',
                            'type':str,
                            'default':'S',# Genera un encabezado de poliza.
                            'required':False 
                        },
                        {  'order':10,
                            'name':'MontoPagado',
                            'type':Decimal,
                            'default':0,# Global
                            'required':False
                        },
                        {  'order':11,
                            'name':'@PolizaID',
                            'type':int,
                            'default':1,# Global
                            'required':False 
                        },
                        {  'order':12,
                            'name':'@NumErr',
                            'type':int,
                            'default':0,# Global
                            'required':False 
                        },
                        {  'order':13,
                            'name':'@ErrMen',
                            'type':int,
                            'default':0,# Global
                            'required':False 
                        },
                        {  'order':14,
                            'name':'@Consecutivo',
                            'type':int,
                            'default':1,# Global
                            'required':False 
                        },
                        {  'order':15,
                            'name':'ModoPago',
                            'type':str,
                            'default':'E',# Efectivo
                            'required':False 
                        },

                      {  'order':16,
                            'name':'Origen',
                            'type':str,
                            'default':'',# Global
                            'required':False 
                        },
                      {  'order':17,
                            'name':'RespaldaCred',
                            'type':str,
                            'default':'S',# Global
                            'required':False 
                        },

                      {  'order':18,
                            'name':'Usuario',
                            'type':int,
                            'default':1,
                            'required':False 
                        },

                      {  'order':19,
                            'name':'FechaActual',
                            'type':str,
                            'default':'1900-01-01',
                            'required':False 
                        },                   
                        {  'order':20,
                            'name':'IP',
                            'type':str,
                            'default':'127.0.0.1',
                            'required':False 
                        },
                        {  'order':21,
                            'name':'ProgramaID',
                            'type':str,
                            'default':'API',
                            'required':False 
                        },
                        {  'order':22,
                            'name':'Sucursal',
                            'type':int,
                            'default':1,
                            'required':False 
                        },
                        {  'order':23,
                            'name':'Transaccion',
                            'type':int,
                            'default':1,
                            'required':False 
                        },
                        
                        ]
            },
            ]