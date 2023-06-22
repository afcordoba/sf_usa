public class aSiteUtils {
	public aSiteUtils() {
	}

	public class myOppRepItem {
		public String id { get; set; }
		public String variedad { get; set; }
		public String variedad_registro { get; set; }
		public String brand { get; set; }
		public String categoria { get; set; }
		public String categoria_id { get; set; }
		public String comentarios { get; set; }
		public String tipo_reporte { get; set; }
		public String forecast { get; set; }
		public String update_status { get; set; }
		public String variedad_licencia_id { get; set; }
		public Date drop { get; set; }
		public Date license { get; set; }

		public Integer purchased { get; set; }
		public Integer ws_in { get; set; }
		public Integer ws_out { get; set; }
		public Integer parent_purchased { get; set; }
		public Double test_purchased { get; set; }
		public Integer sales { get; set; }
		public Integer test { get; set; }
		public Integer used { get; set; }
		public Integer used_dm_prod { get; set; }
		public Integer comm_sales { get; set; }
		public Integer total { get; set; }
		public Integer forecast_quantity { get; set; }

		public Integer forecast_prev { get; set; }
		public Integer area_prev { get; set; }
		public Integer bushel_prev { get; set; }
		public Integer supply_prev { get; set; }

		public Integer fore_range_min_quantity { get; set; }
		public Integer fore_range_max_quantity { get; set; }
		public Integer update_area { get; set; }
		public Integer update_bushels { get; set; }
		public Integer update_estimate { get; set; }
		public Integer production_area { get; set; }
		public Integer optional_area { get; set; }
		public Integer production_bushels { get; set; }
		public Integer conditioned_140k { get; set; }
		public Integer unconditioned_bushels { get; set; }
		public Integer discarded_bushels { get; set; }
		public Integer net_traits { get; set; }
		public Integer replants { get; set; }
		public Double precio { get; set; }
		public Double royalty_rate { get; set; }
	}

	public class retorno {
		public String id { get; set; }
		public String mensaje { get; set; }
		public Boolean exito { get; set; }
	}

	public static List<String> getDatosCombo(String entity, String field) {
		List<String> ret = new List<String>();
		Schema.SObjectType objType = Schema.getGlobalDescribe().get(entity);
		Schema.DescribeSObjectResult describeResult = objType.getDescribe();
		Schema.DescribeFieldResult fieldInfo = describeResult.fields.getMap().get(field).getDescribe();
		List<Schema.PickListEntry> p_f = fieldInfo.getPickListValues();
		for (Schema.PickListEntry p : p_f) {
			String descrip = p.getvalue();
			ret.add(descrip);
		}
		return ret;
	}

	public static String querySelect(SObjectType entity) {
		return 'select ' + string.join(new List<string>(entity.getdescribe().fields.getmap().keyset()), ',');
	}
	public static String queryFromSObject(SObjectType entity, String plus) {
		String extra = (plus != null) ? ', ' + plus : '';
		return querySelect(entity) + extra + ' from ' + string.valueof(entity);
	}
	public static SObject[] queryResults1(SObjectType entity, String queryPlus, String fn1, Object v1) {
		return Database.query(queryFromSObject(entity, queryPlus) + ' where ' + fn1 + ' Order By Name');
	}

	public static SObject[] queryResults1WithOrderByField(
		SObjectType entity,
		String queryPlus,
		String fn1,
		Object v1,
		String orderField
	) {
		return Database.query(queryFromSObject(entity, queryPlus) + ' where ' + fn1 + ' Order By ' + orderField);
	}
	public static SObject[] queryResults2(
		SObjectType entity,
		String queryPlus,
		String fn1,
		Object v1,
		String fn2,
		Object v2
	) {
		return Database.query(queryFromSObject(entity, queryPlus) + ' where ' + fn1 + ' and ' + fn2 + ' Order By Name');
	}
	public static SObject[] queryResults2b(
		SObjectType entity,
		String queryPlus,
		String fn1,
		Object v1,
		String fn2,
		Object v2
	) {
		return Database.query(
			queryFromSObject(entity, queryPlus) +
			' where ' +
			fn1 +
			' and ' +
			fn2 +
			' Order By LastModifiedDate desc'
		);
	}
	public static SObject[] queryResults3(
		SObjectType entity,
		String queryPlus,
		String fn1,
		Object v1,
		String fn2,
		Object v2,
		String fn3,
		Object v3
	) {
		return Database.query(
			queryFromSObject(entity, queryPlus) +
			' where ' +
			fn1 +
			' and ' +
			fn2 +
			' and ' +
			fn3 +
			' Order By Name'
		);
	}
	public static SObject[] queryResults4(
		SObjectType entity,
		String queryPlus,
		String fn1,
		Object v1,
		String fn2,
		Object v2,
		String fn3,
		Object v3,
		String fn4,
		Object v4
	) {
		return Database.query(
			queryFromSObject(entity, queryPlus) +
			' where ' +
			fn1 +
			' and ' +
			fn2 +
			' and ' +
			fn3 +
			' and ' +
			fn4 +
			' Order By Name'
		);
	}

	public static SObject[] queryResults4WithOrderBy(
		SObjectType entity,
		String queryPlus,
		String fn1,
		Object v1,
		String fn2,
		Object v2,
		String fn3,
		Object v3,
		String fn4,
		Object v4,
		String orderField
	) {
		return Database.query(
			queryFromSObject(entity, queryPlus) +
			' where ' +
			fn1 +
			' and ' +
			fn2 +
			' and ' +
			fn3 +
			' and ' +
			fn4 +
			' Order By ' +
			orderField
		);
	}
	public static SObject[] queryResults5(
		SObjectType entity,
		String queryPlus,
		String fn1,
		Object v1,
		String fn2,
		Object v2,
		String fn3,
		Object v3,
		String fn4,
		Object v4,
		String fn5,
		Object v5
	) {
		return Database.query(
			queryFromSObject(entity, queryPlus) +
			' where ' +
			fn1 +
			' and ' +
			fn2 +
			' and ' +
			fn3 +
			' and ' +
			fn4 +
			' and ' +
			fn5 +
			' Order By Name'
		);
	}
	public static SObject[] queryResults5WithOrderBy(
		SObjectType entity,
		String queryPlus,
		String fn1,
		Object v1,
		String fn2,
		Object v2,
		String fn3,
		Object v3,
		String fn4,
		Object v4,
		String fn5,
		Object v5,
		String orderField
	) {
		return Database.query(
			queryFromSObject(entity, queryPlus) +
			' where ' +
			fn1 +
			' and ' +
			fn2 +
			' and ' +
			fn3 +
			' and ' +
			fn4 +
			' and ' +
			fn5 +
			' Order By ' +
			orderField
		);
	}

	//USO: queryResults(Account.SObjectType, 'CreatedDate < :v1', DateTime.Now(), 'Name IN :v2', new String[] { 'Acme' });
}