class Repository():
    Integracion=[
       {'routine':'PGSSALDOSREP',
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
       {'routine':'PGSSALDOSREP',
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
                     'name':'Transaccion',#OrigenID
                     'type':'int',
                      'default':0,
                     'required':True
                    },
                                        
                    {'order':'4',
                     'name':'Consolidado',# Option
                     'type':str,
                     'default':'S', 
                     'required':False 
                    },

                    ]
       },
    ]
    

