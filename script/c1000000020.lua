local s,id=GetID()
-- Global variable to keep track of Special Summon status
s.summonedThisTurn = false

function s.initial_effect(c)
    --Pendulum attributes
    Pendulum.AddProcedure(c)
    -- Track Special Summon status
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e0:SetCode(EVENT_SPSUMMON_SUCCESS)
    e0:SetLabelObject(c)
    e0:SetOperation(s.trackop)
    Duel.RegisterEffect(e0,0)
    -- Reset the tracking at the end of the turn
    local e0b=Effect.CreateEffect(c)
    e0b:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e0b:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e0b:SetCode(EVENT_TURN_END)
    e0b:SetOperation(s.resetop)
    Duel.RegisterEffect(e0b,0)
    -- Pendulum effect 1: Add 1 Dragon monster from your Deck to your hand.
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_MOVE)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetRange(LOCATION_PZONE)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.pencon1)
    e1:SetTarget(s.pentg)
    e1:SetOperation(s.penop)
    c:RegisterEffect(e1)
    -- Pendulum effect 2: Special Summon this card from the Pendulum Zone.
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_PZONE)
    e2:SetCountLimit(1,id+1)
    e2:SetCost(s.spcost)
    e2:SetTarget(s.sptg)
    e2:SetOperation(s.spop)
    e2:SetCondition(s.sscon)  -- Updated condition function
    c:RegisterEffect(e2)
    -- Synchro summon procedure
    Synchro.AddProcedure(c,nil,1,1,Synchro.NonTuner(nil),1,99)
    -- Direct attack
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetCode(EFFECT_DIRECT_ATTACK)
    c:RegisterEffect(e3)
    -- Return to Pendulum Zone
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e4:SetCode(EVENT_PHASE+PHASE_BATTLE)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCountLimit(1)
    e4:SetCondition(s.retcon)
    e4:SetOperation(s.retop)
    c:RegisterEffect(e4)
end

-- Function to track Special Summon status
function s.trackop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetLabelObject()
    if eg:IsContains(c) then
        s.summonedThisTurn = true
    end
end

-- Function to reset the tracking at the end of the turn
function s.resetop(e,tp,eg,ep,ev,re,r,rp)
    s.summonedThisTurn = false
end

-- Updated condition function for the discard effect
function s.sscon(e,tp,eg,ep,ev,re,r,rp)
    return not s.summonedThisTurn
end

-- (rest of your script remains unchanged)
function s.pencon1(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsLocation(LOCATION_PZONE)
end

function s.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.penfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.penfilter(c)
    return c:IsRace(RACE_DRAGON) and c:IsAbleToHand()
end

function s.penop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.penfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end

function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,nil) end
    Duel.DiscardHand(tp,s.costfilter,1,1,REASON_COST+REASON_DISCARD)
end

function s.costfilter(c)
    return c:IsRace(RACE_DRAGON) and c:IsDiscardable()
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
        Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
    end
end

function s.retcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():GetBattledGroupCount()>0
end

function s.retop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) and (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1)) then
        Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
    end
end