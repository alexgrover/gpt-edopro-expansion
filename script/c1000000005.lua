local s,id=GetID()
function s.initial_effect(c)
    -- Cannot be banished
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_CANNOT_REMOVE)
    c:RegisterEffect(e1)

    -- Return banished cards to the owner's Deck
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_REMOVE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCondition(s.rmcon)
    e2:SetOperation(s.rmop)
    c:RegisterEffect(e2)

    -- Gain ATK
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e3:SetCode(EVENT_REMOVE)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCondition(s.atkcon)
    e3:SetOperation(s.atkop)
    c:RegisterEffect(e3)
end

function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(Card.IsAbleToDeck,1,nil)
end

function s.rmop(e,tp,eg,ep,ev,re,r,rp)
    local g=eg:Filter(Card.IsAbleToDeck,nil)
    Duel.SendtoDeck(g,nil,2,REASON_EFFECT)
end

function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(Card.IsAbleToDeck,1,nil)
end

function s.atkop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) and c:IsFaceup() then
        local atk=eg:FilterCount(Card.IsAbleToDeck,nil)*200
        -- Create a temporary effect to update the ATK
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetValue(atk)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
        c:RegisterEffect(e1)
    end
end
