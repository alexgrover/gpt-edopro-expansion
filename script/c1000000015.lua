local s,id=GetID()
function s.initial_effect(c)
    --special summon rule
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetRange(LOCATION_EXTRA)
    e1:SetCondition(s.spcon)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)
    --fusion summon
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,id)
    e2:SetTarget(s.fstg)
    e2:SetOperation(s.fsop)
    c:RegisterEffect(e2)
    --return to extra deck
    local e3=Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_TOEXTRA)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetCountLimit(1,id+1)
    e3:SetCost(s.tecost)
    e3:SetTarget(s.tetg)
    e3:SetOperation(s.teop)
    c:RegisterEffect(e3)
end
s.listed_series={0x7D0}

function s.spfilter(c,ft,tp)
	return c:IsSetCard(0x7D0) and c:IsType(TYPE_NORMAL) and c:IsAbleToHand()
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	return ft>-2 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_MZONE,0,2,nil,ft,tp)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_MZONE,0,2,2,nil)
	Duel.SendtoHand(g,nil,REASON_COST)
end

function s.filter1(c,e)
    return not c:IsImmuneToEffect(e)
end
function s.fstg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        local mg=Duel.GetFusionMaterial(tp):Filter(s.filter1,nil,e)
        local res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,mg)
        return res
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.filter2(c,mg)
    return c:IsType(TYPE_FUSION) and c:IsSetCard(0x7D0) and not c:IsCode(id) and c:CheckFusionMaterial(mg,nil,tp)
end
function s.fsop(e,tp,eg,ep,ev,re,r,rp)
    local mg=Duel.GetFusionMaterial(tp):Filter(s.filter1,nil,e)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local sg=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_EXTRA,0,1,1,nil,mg)
    local tc=sg:GetFirst()
    if tc then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FMATERIAL)
        local mat=Duel.SelectFusionMaterial(tp,tc,mg,nil,tp,nil,nil)
        tc:SetMaterial(mat)
        Duel.SendtoGrave(mat,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
        Duel.BreakEffect()
        Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
        tc:CompleteProcedure()
    end
end



function s.tecost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsSetCard,1,nil,0x7D0) end
	local g=Duel.SelectReleaseGroup(tp,Card.IsSetCard,1,1,nil,0x7D0)
	Duel.Release(g,REASON_COST)
end
function s.tetg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToExtra() end
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,e:GetHandler(),1,0,0)
end
function s.teop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SendtoDeck(c,nil,0,REASON_EFFECT)
	end
end
