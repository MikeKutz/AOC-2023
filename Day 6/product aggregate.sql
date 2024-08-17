create or replace
type product_t as object (
  product number
  
  ,static function ODCIAggregateInitialize( actx in out nocopy product_t) return number
  ,member function ODCIAggregateIterate(self         in out nocopy product_t, p number) return number
  ,member function ODCIAggregateMerge(self in out nocopy product_t, other_p in product_t) return number
  ,member function ODCIAggregateTerminate(self      in out nocopy product_t
                          ,return_value out number
                          ,flags       in  number) return number
);
/

--- ODCIConst.Success

create or replace
type body product_t
as
  static function ODCIAggregateInitialize( actx in out nocopy product_t) return number
  as
  begin
    actx := new product_t( null );
    
    return ODCIConst.Success;
  end;
  
  member function ODCIAggregateIterate(self         in out nocopy product_t, p number) return number
  as
  begin
    self.product := nvl( self.product * p, p);
  
    return ODCIConst.Success;
  end;

  member function ODCIAggregateMerge(self in out nocopy product_t, other_p in product_t) return number
  as
  begin
    self.product := self.product * nvl( other_p.product, 1);
  
    return ODCIConst.Success;
  end;

  
  member function ODCIAggregateTerminate(self      in out nocopy product_t
                          ,return_value out number
                          ,flags       in  number) return number
  as
  begin
    return_value := self.product;
  
    return ODCIConst.Success;
  end;
  
end product_t;
/

create or replace
function product( p in number ) return number
 aggregate using product_t;
/

-- UT 
select product( d.T ) as abc
from (
  select 5 T union all
  select 6
) d;

