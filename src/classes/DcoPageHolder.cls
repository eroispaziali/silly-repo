global virtual class DcoPageHolder 
{
      public Integer pageSize;
      public Integer pageNumber;
      public String[] pageOrder;
      public Integer totalElements;
      public sObject[] content;
      public Integer numberOfElements { get{ return content.size();} }
      public Integer firstElementOrdinal { get{ return pageNumber*pageSize;} }
      public Integer lastElementOrdinal { get{ return firstElementOrdinal+numberOfElements - 1;} }
      public Boolean firstPage { get{ return pageNumber == 0;} }
      public Boolean lastPage { get{ return lastElementOrdinal >= totalElements - 1;} }
      public Integer totalPages { get{ return (Integer)Math.floor(totalElements/pageSize) + (Math.mod(totalElements,pageSize)>0?1:0);} }
      public String jsClass { get{ return 'PageHolder';} }
}