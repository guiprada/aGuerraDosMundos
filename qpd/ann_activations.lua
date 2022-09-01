local ann_activations = {}

function ann_activations.identity(a)
	return a
end

function ann_activations.binary_step(a)
	if a >= 0 then
		return 1
	else
		return 0
	end
end

function ann_activations.sigmoid(a, p)
	p = p or 1
	return 1 / (1 + math.exp(-a/p))
end

function ann_activations.tanh(a)
	return (math.exp(a) - math.exp(-a))/(math.exp(a) + math.exp(-a))
end

function ann_activations.tanh_lua(a)
	return math.tanh(a)
end

function ann_activations.relu(a)
	if a <= 0 then
		return 0
	else
		return a
	end
end

function ann_activations.softplus(a)
	return math.log(1 + math.exp(a))
end

function ann_activations.silu(a)
	return a/(1 + math.exp(-a))
end

return ann_activations