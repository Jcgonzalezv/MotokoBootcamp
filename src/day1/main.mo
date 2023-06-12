import Int "mo:base/Int";
import Float "mo:base/Float";

actor class Calculator() {
    // Paso 1 -  Define una variable mutable llamada `counter`.
    var counter : Float = 0;
    
    // Paso 2 - Implementa el add
    public func add(x : Float) : async Float {
    counter += x;
    return counter;
    };
    
    // Paso 3 - Implementa el sub 
    public func sub(x : Float) : async Float {
    counter-=x;
    return counter;
    };
    
    // Paso 4 - Implementa el mul 
    public func mul(x : Float) : async Float {
       counter *= x;
       return counter;
    };
    
    // Paso 5 - Implementa el div 
    public func div(x : Float) : async Float {
      if(x==0){
        return 0;
      }
      else
      {
        counter /=x;
        return counter;
      }
    };
    
    // Paso 6 - Implementa el reset 
    public func reset(): async () {
       counter := 0;
    };
    
    // Paso 7 - Implementa el query 
    public query func see() : async Float {
        return counter;
    };
    
    // Paso 8 - Implementa el power 
    public func power(x : Float) : async Float {
        counter **= x;
        return counter;
    };
    
    // Paso 9 - Implementa el sqrt 
    public func sqrt() : async Float {
        counter := Float.sqrt(counter);
        return counter;
    };
    
    // Paso 10 - Implementa el floor 
    public func floor() : async Int {

      return Float.toInt(counter);
     
      }
};
