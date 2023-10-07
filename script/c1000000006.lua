local s,id=GetID()
function s.initial_effect(c)
    -- Activate
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCost(s.cost)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
    -- Atk down & LP loss
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
    e2:SetRange(LOCATION_FZONE)
    e2:SetCountLimit(1)
    e2:SetCondition(s.atkcon)
    e2:SetOperation(s.atkop)
    c:RegisterEffect(e2)
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.CheckLPCost(tp,1000) end
    Duel.PayLPCost(tp,1000)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsPlayerCanSpecialSummonMonster(tp,1000000007,0,TYPES_TOKEN_MONSTER,3000,3000,8,RACE_MACHINE,ATTRIBUTE_DARK) end
    local token=Duel.CreateToken(tp,1000000007)
    Duel.SetOperationInfo(0,CATEGORY_TOKEN,token,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,token,1,tp,0)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    if not e:GetHandler():IsRelateToEffect(e) then return end
    if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsPlayerCanSpecialSummonMonster(tp,1000000007,0,TYPES_TOKEN_MONSTER,3000,3000,8,RACE_MACHINE,ATTRIBUTE_DARK) then
        local token=Duel.CreateToken(tp,1000000007)
        Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP_ATTACK)
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UNRELEASABLE_SUM)
        e1:SetValue(1)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        token:RegisterEffect(e1,true)
        local e2=e1:Clone()
        e2:SetCode(EFFECT_UNRELEASABLE_NONSUM)
        token:RegisterEffect(e2,true)
        local e3=e1:Clone()
        e3:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
        token:RegisterEffect(e3,true)
        local e4=e1:Clone()
        e4:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
        token:RegisterEffect(e4,true)
    end
end

function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,1000000007)
end

function s.atkop(e,tp,eg,ep,ev,re,r,rp)
    local token=Duel.GetFirstMatchingCard(Card.IsCode,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,1000000007)
    if token then
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetValue(-100)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
        token:RegisterEffect(e1)
        if Duel.GetLP(tp)>200 then
            Duel.SetLP(tp,Duel.GetLP(tp)-200)
        else
            Duel.SetLP(tp,0)
        end
    end
end