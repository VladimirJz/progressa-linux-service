class Repository():
    Client=[
       {'routine':'CLIENTESCON',
        'option':1,
        'request':'retrieve',
        'output':'row',
       'parameters':
                    [{'order':'1',
                     'name':'ClienteID',
                     'type':'int',
                      'default':'0',
                     'required':'True' 
                    },
                     {'order':'2',
                     'name':'RFC',
                     'type':'varchar',
                      'default':"''",
                     'required':'True' 
                    },
                    {'order':'3',
                     'name':'CURP',
                     'type':'int',
                      'default':'0',
                     'required':'True' 
                    },
                                        
                    {'order':'3',
                     'name':'NumCon',# Option
                     'type':'int',
                     'default':'1', # Retrieve
                     'required':'True' 
                    },

                    ]
       },
        
       {'routine':'CLIENTESCON',
        'option':7,
        'request':'resume',
        'output':'row'
        },
        {
        'routine':'DIRECCLIENTELIS',
        'option':1,
        'request':'address',
        'output':'table',
       'parameters':
                    [{'order':1,
                     'name':'ClienteID',
                     'type':int,
                      'default':0,
                     'required':True 
                    },
                     {'order':2,
                     'name':'DirecComple',
                     'type':str,
                      'default':"",
                     'required':False 
                    },
                    {'order':3,
                     'name':'NumList',
                     'type':int,
                      'default':1,# Principal
                     'required':True 
                    },
                                        
                    ]
        }
        
    ]