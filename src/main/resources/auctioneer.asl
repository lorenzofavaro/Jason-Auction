start_price(X) :- .random(R) & X = math.round(R * 10).
res_price(X, Y) :- .random(R) & Y = math.round(R*10) + X.
p_upgrade(X) :- .random(R) & X = math.round(R * 5) + 1.
participants(3).

// Inizio asta
+!start_auction(N)
    :   true
    <-  
        ?start_price(X);
        ?res_price(X, Y);
        ?p_upgrade(Z);
        +price_upgrade(N,Z);
        +reservation_price(N,Y);
        .print("\n\nNuova Asta! Si parte da ", X);
        !get_offers(N, 0, X).


// Comunicazione dell'attuale prezzo
+!get_offers(N, Call, CurrentPrice)
    :   true
    <- 
        .print("Qualcuno offre ", CurrentPrice, "?");
        .broadcast(tell, auction(N, Call, CurrentPrice)).


// C'è almeno qualcuno che accetta la proposta, si va avanti
@pb1(atomic)
+place_bid(N, Call, CurrentPrice)[source(A)]
    :   not accepted(N, CurrentPrice, _) &
        price_upgrade(N,Pu) &
        not accepted(N, CurrentPrice-Pu, A)
    <- 
        .print("Offerta di ", A, " accettata");
        .abolish(accepted(N, _, _));
        +accepted(N, CurrentPrice, A);
        .send(A, tell, accepted(N, Call, CurrentPrice));
        .abolish(refuse_bid(N, _));
        !get_offers(N, Call+1, CurrentPrice+Pu).


// Comunica all'agente se la sua proposta è stata rifiutata
@pb2(atomic)
+place_bid(N, Call, CurrentPrice)[source(A)]
    :   accepted(N, CurrentPrice, X) & not(X = A)
    <- 
        .send(A, tell, refused(N, Call, CurrentPrice)).


// Termina l'asta
+!finish_auction(N, CurrentPrice, W)
    :   true
    <-
        ?price_upgrade(N,Pu);
        ?reservation_price(N,Rp);
        LastBid = CurrentPrice - Pu;
        if (LastBid >= Rp) {
            .print("Abbiamo un vincitore: ", W, " si aggiudica il quadro per ", LastBid, "!");
            show_winner(N,W);
            .broadcast(tell, winner(N,W));
        } else {
            .print("Il notaio rifiuta l'ultima offerta! Il suo prezzo minimo era ", Rp);
            stop_auction(N);
        }
        .abolish(place_bid(N,_,_)).


// Se non ci sono più offerenti, termina l'asta assegnando (nel caso) la vittoria all'ultimo offerente
+refuse_bid(N, CurrentPrice)
    :   .findall(b(V,A),refuse_bid(N,CurrentPrice)[source(A)],L) &
        participants(X) &
        .length(L,X) &
        price_upgrade(N,Pu) &
        accepted(N, CurrentPrice-Pu, W)
    <-
        .print("... Nessuno?\n...");
        !finish_auction(N, CurrentPrice, W).