local _hefty={
	bank_manager_key=5,
	lance_part=2,
	boards=5,
	planks=5,
	thermite_paste=2,
	gas=2,
	acid=3,
	caustic_soda=3,
	hydrogen_chloride=3,
	evidence=2
	}

for name, quantity in pairs(_hefty) do
	tweak_data.equipments.specials[name].quantity=1
	tweak_data.equipments.specials[name].max_quantity=quantity
	end