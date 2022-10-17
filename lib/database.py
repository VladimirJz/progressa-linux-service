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
    


    #"call PGS_MAESTROSALDOS('I','T',556,'S') ") 