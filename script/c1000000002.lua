-- Your custom monster
local s,id=GetID()
function s.initial_effect(c)
    -- Cannot be Normal Summoned/Set
    c:EnableUnsummonable()
    
    -- Special Summon condition
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SPSUM_PARAM)
    e1:SetRange(LOCATION_HAND)
    e1:SetTargetRange(POS_FACEUP,0)
    e1:SetCondition(s.spsumcon)
    e1:SetOperation(s.spsumop)
    e1:SetValue(SUMMON_TYPE_SPECIAL)
    c:RegisterEffect(e1)
end

function s.venomfilter(c)
    return c:IsFaceup() and c:GetCounter(0x1009)>0
end

function s.spsumcon(e,c)
    if c==nil then return true end
    local tp=c:GetControler()
    return Duel.CheckReleaseGroupCost(tp,s.venomfilter,1,false,nil,nil) or Duel.CheckReleaseGroupCost(1-tp,s.venomfilter,1,false,nil,nil)
end

function s.spsumop(e,tp,eg,ep,ev,re,r,rp,c)
    local g
    if Duel.CheckReleaseGroupCost(tp,s.venomfilter,1,false,nil,nil) then
        g=Duel.SelectReleaseGroupCost(tp,s.venomfilter,1,99,false,nil,nil)
    else
        g=Duel.SelectReleaseGroupCost(1-tp,s.venomfilter,1,99,false,nil,nil)
    end
    local ct=Duel.SendtoGrave(g,REASON_SUMMON+REASON_MATERIAL)
    local atk=ct*1000
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_SET_BASE_ATTACK)
    e1:SetValue(c:GetBaseAttack()+atk)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE+RESET_TOFIELD)
    c:RegisterEffect(e1)
end
