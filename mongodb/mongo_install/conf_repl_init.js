rs.initiate(
	{
		_id: "replconfig01",
		configsvr: true,
		members: [
			{ _id : 0, host : "127.0.0.1:57040" }
		]
	}
)
