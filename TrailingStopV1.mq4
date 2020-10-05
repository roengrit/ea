//+------------------------------------------------------------------+
//|                                               TrailingStopV1.mq4 |
//|                                              Copyright 2016, Pok |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Pok"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

extern double  stopLossPips   = 20; // Trailing Stop (pips)
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
   setTrailingStop();
  }
//+------------------------------------------------------------------+
void setTrailingStop()
  {
double buyTrailingStop  = 0.0;
double sellTrailingStop = 0.0;
double stoplossPip = 0.0;
bool   ordm;
  
  
double   order_ask;
double   order_bid;
double   order_point;
double   order_digit;
double   order_stoplevel;
  
   for(int i=0; i<OrdersTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS) && OrderComment()=="")
        {
            order_ask = MarketInfo(OrderSymbol(),MODE_ASK);
            order_bid =  MarketInfo(OrderSymbol(),MODE_BID);    
            order_point = MarketInfo(OrderSymbol(),MODE_POINT);
            order_digit = MarketInfo(OrderSymbol(),MODE_DIGITS);
            order_stoplevel = MarketInfo(OrderSymbol(),MODE_STOPLEVEL);
         
            if(stopLossPips < order_stoplevel) stoplossPip =  order_stoplevel;
            else stoplossPip = stopLossPips;
            
         if(OrderType() == OP_BUY)
           {
      
               buyTrailingStop=NormalizeDouble(order_bid-stoplossPip*order_point,order_digit);
               if((buyTrailingStop>OrderStopLoss()&& OrderStopLoss() !=0) || ( buyTrailingStop > OrderOpenPrice() && OrderStopLoss() == 0 ) )
                 {
                  ordm=OrderModify(OrderTicket(),OrderOpenPrice(),buyTrailingStop,OrderTakeProfit(),0,CLR_NONE);
                  if(!ordm) 
                     Print("Error in OrderModify. Error code=",GetLastError()); 
                  else 
                     Print("Order modified successfully.");

                 //Print(OrderSymbol(),order_bid,"=ts",buyTrailingStop,">op",OrderOpenPrice());
                 }

               //---
          }else if(OrderType() == OP_SELL)
          {
               //sellTrailingStop=NormalizeDouble(Ask+stopLossPips*Point,Digits);
               sellTrailingStop=NormalizeDouble(order_ask+stoplossPip*order_point,order_digit);
                
               if((sellTrailingStop<OrderStopLoss()&& OrderStopLoss() !=0) || (sellTrailingStop < OrderOpenPrice() && OrderStopLoss() == 0))
                 {
//                  ordm=OrderModify(OrderTicket(),OrderOpenPrice(),sellTrailingStop,OrderTakeProfit(),0,CLR_NONE);
                  ordm=OrderModify(OrderTicket(),OrderOpenPrice(),sellTrailingStop,OrderTakeProfit(),0,CLR_NONE);
                  if(!ordm) 
                     Print("Error in OrderModify. Error code=",GetLastError()); 
                  else 
                     Print("Order modified successfully."); 
                 //Print(OrderSymbol(),order_ask,"=ts",sellTrailingStop,"<op",OrderOpenPrice());

                 }
               
           }
        }
     }
  }


//+------------------------------------------------------------------+
