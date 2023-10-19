local s,id=GetID()
function s.initial_effect(c)
    --Pendulum Set
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_SYNCHRO_MATERIAL_CUSTOM)
    e1:SetValue(1)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetCondition(s.syncon)
    c:RegisterEffect(e1)
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_BE_BATTLE_TARGET)
    e2:SetRange(LOCATION_PZONE)
    e2:SetCondition(s.pencon)
    e2:SetOperation(s.penop)
    c:RegisterEffect(e2)
    --Pendulum Effect
    local e3=Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
    e3:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    e3:SetRange(LOCATION_PZONE)
    e3:SetCountLimit(1,id)
    e3:SetTarget(s.thtg)
    e3:SetOperation(s.thop)
    c:RegisterEffect(e3)
    --Synchro Summon from Pendulum Zone
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD)
    e4:SetCode(EFFECT_SPSUMMON_PROC)
    e4:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
    e4:SetRange(LOCATION_PZONE)
    e4:SetCondition(s.hspcon)
    e4:SetTarget(s.hsptg)
    e4:SetOperation(s.hspop)
    e4:SetValue(SUMMON_TYPE_SYNCHRO)
    c:RegisterEffect(e4)
    --Attack Directly
    local e5=Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_SINGLE)
    e5:SetCode(EFFECT_DIRECT_ATTACK)
    c:RegisterEffect(e5)
    --Return to Pendulum Zone on Attack Declaration
    local e6=Effect.CreateEffect(c)
    e6:SetCategory(CATEGORY_TODECK)
    e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e6:SetCode(EVENT_ATTACK_ANNOUNCE)
    e6:SetTarget(s.rettg)
    e6:SetOperation(s.retop)
    c:RegisterEffect(e6)
end
s.pendulum_level=8 --Pendulum Scale

function s.syncon(e)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end

function s.pencon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:IsFaceup() and c:IsCanBeEffectTarget(e)
end

function s.penop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) and not c:IsImmuneToEffect(e) then
        Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
    end
end

function s.thfilter(c)
    return c:IsRace(RACE_DRAGON) and c:IsAbleToHand()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end

function s.hspcon(e,c)
    if c==nil then return true end
    local tp=c:GetControler()
    return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
end

function s.hsptg(e,tp,eg,ep,ev,re,r,rp,c)
    local c=e:GetHandler()
    local tp=c:GetControler()
    local mg=Duel.GetMatchingGroup(Card.IsCanBeSynchroMaterial,tp,LOCATION_MZONE,LOCATION_MZONE,c,c)
    local g=Duel.GetMatchingGroup(Card.IsCanBeSynchroMaterial,tp,LOCATION_MZONE,LOCATION_MZONE,nil,c)
    local sg=g:Filter(s.filter,nil,c)
    mg:Merge(sg)
    local res=Duel.SelectSynchroMaterial(tp,c,mg,1,99,Duel.GetMatchingGroup(nil,tp,LOCATION_MZONE,LOCATION_MZONE,nil),0)
    return res
end

function s.hspop(e,tp,eg,ep,ev,re,r,rp,c)
    local tp=c:GetControler()
    local mg=Duel.GetMatchingGroup(Card.IsCanBeSynchroMaterial,tp,LOCATION_MZONE,LOCATION_MZONE,c,c)
    local g=Duel.GetMatchingGroup(Card.IsCanBeSynchroMaterial,tp,LOCATION_MZONE,LOCATION_MZONE,nil,c)
    local sg=g:Filter(s.filter,nil,c)
    mg:Merge(sg)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SMATERIAL)
    local mat=Duel.SelectSynchroMaterial(tp,c,mg,1,99,Duel.GetMatchingGroup(nil,tp,LOCATION_MZONE,LOCATION_MZONE,nil),0)
    c:SetMaterial(mat)
    Duel.SendtoGrave(mat,REASON_MATERIAL+REASON_SYNCHRO)
end

function s.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsAbleToDeck() end
    Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
end

function s.retop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) then
        Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
    end
end
