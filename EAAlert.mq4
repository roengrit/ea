//+------------------------------------------------------------------+
//|                                                      EAAlert.mq4 |
//|                                        Copyright 2020, Roengrit. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, Roengrit."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

input string Token ="";

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   double balance = AccountBalance();
   double eq =  AccountEquity();

   if(balance/2 >= eq)
     {
      
      string headers;
      char data[], result[];

      headers="Authorization: Bearer "+Token+"\r\n	application/x-www-form-urlencoded\r\n";
      ArrayResize(data,StringToCharArray("message=ตรวจสอบยอด Balance "+ (balance/2)+  " : " + (eq)   ,data,0,WHOLE_ARRAY,CP_UTF8)-1);
      int res = WebRequest("POST", "https://notify-api.line.me/api/notify", headers, 0, data, data, headers);
      if(res==-1)
        {
         Print("Error in WebRequest. Error code  =",GetLastError());
         MessageBox("Add the address 'https://notify-api.line.me' in the list of allowed URLs on tab 'Expert Advisors'","Error",MB_ICONINFORMATION);
        }

     }
   else
     {

      Print(balance/2," ", eq);

     }



  }
//+------------------------------------------------------------------+
