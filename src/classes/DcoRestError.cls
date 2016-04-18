global class DcoRestError 
{
   Integer status;
   String message;
   Datetime timestamp;
   String diagnosticMessage;
   String exceptionType;
   
   String jsClass { get{ return 'RestError';} }
   
   public DcoRestError(Exception e)
   {
   	this(null, e);
   }
   public DcoRestError(String msg, Exception e)
   {
      status = 500;
      message = msg== null ? e.getMessage() : msg;
      timestamp = Datetime.now();
      diagnosticMessage = e.getStackTraceString();
      exceptionType = String.valueOf(e);
   }
}