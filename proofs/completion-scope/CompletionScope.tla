------------------------- MODULE CompletionScope -------------------------
EXTENDS Naturals
CONSTANTS ReferencePolicy, MaxOperations
VARIABLES connection, owner, fresh, requested, shown, event, operations
vars == <<connection, owner, fresh, requested, shown, event, operations>>
Contexts == {"A1", "A2", "B1"}
Server(c) == IF c = "B1" THEN "B" ELSE "A"
Init == /\ connection = "A1" /\ owner = "none" /\ fresh = FALSE
        /\ requested = "none" /\ shown = "none" /\ event = "Init"
        /\ operations = 0
Connect(c, label) ==
    /\ connection' = c /\ UNCHANGED <<owner, fresh>>
    /\ requested' = "none" /\ shown' = "none" /\ event' = label
    /\ operations' = operations + 1
Complete(explicit) ==
    LET target == IF explicit THEN "B1" ELSE connection
        fetch == IF ReferencePolicy THEN target ELSE connection
        hit == fresh /\ (~ReferencePolicy \/ owner = target)
        value == IF hit THEN owner ELSE fetch
    IN /\ owner' = value /\ fresh' = TRUE /\ connection' = connection
       /\ requested' = target /\ shown' = value
       /\ event' = IF explicit THEN "CompleteExplicitB" ELSE "CompleteDefault"
       /\ operations' = operations + 1
Reset(label, newOwner, newConnection) ==
    /\ owner' = newOwner /\ fresh' = FALSE /\ connection' = newConnection
    /\ requested' = "none" /\ shown' = "none" /\ event' = label
    /\ operations' = operations + 1
Next == /\ operations < MaxOperations
        /\ (Connect("B1", "ConnectB") \/ Connect("A2", "RotateA")
            \/ Connect("A1", "ConnectA") \/ Connect("B1", "FailedConnectB")
            \/ Complete(FALSE) \/ Complete(TRUE)
            \/ Reset("Expire", owner, connection)
            \/ Reset("Clear", "none", connection)
            \/ Reset("ExpireFetchFailure", owner, connection)
            \/ Reset("ExpireFetchEmpty", owner, connection)
            \/ Reset("UnloadReload", "none", "A1"))
Spec == Init /\ [][Next]_vars
TypeOK == /\ connection \in Contexts /\ owner \in Contexts \cup {"none"}
          /\ fresh \in BOOLEAN /\ requested \in Contexts \cup {"none"}
          /\ shown \in Contexts \cup {"none"} /\ operations \in 0..MaxOperations
DefaultServerIsolation == event = "CompleteDefault" => Server(shown) = Server(requested)
DefaultCredentialIsolation ==
    (event = "CompleteDefault" /\ Server(shown) = Server(requested)) => shown = requested
ExplicitSessionIsolation == event = "CompleteExplicitB" => shown = requested
FailureDoesNotFreshen == event \in {"ExpireFetchFailure", "ExpireFetchEmpty"} => ~fresh
CleanupRemovesEntry == event \in {"Clear", "UnloadReload"} => owner = "none" /\ ~fresh
=============================================================================
