private_value(14).

// TODO settare private_value random

// Il prezzo attuale è al di sotto del mio private value
+auction(N, Call, CurrentPrice)[source(S)]
    :   private_value(X) & CurrentPrice <= X & not (accepted(N, Call-1, C))
    <-  
        .print("Io!");
        .abolish(auction(N,_,_));
        .send(S, tell, place_bid(N, Call, CurrentPrice)).

// Il prezzo attuale eccede il mio private value
+auction(N, Call, CurrentPrice)[source(S)]
    :   (private_value(X) & CurrentPrice > X) | (accepted(N, Call-1, C))
    <-  
        .abolish(auction(N,_,_));
        .send(S, tell, refuse_bid(N, CurrentPrice)).