rs.initiate(
	{
		_id: "replconfig01",
		configsvr: true,
		members: [
			{ _id : 0, host : "192.168.1.104:57040" }
		]
	}
)
