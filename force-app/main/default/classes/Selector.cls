public abstract class Selector {
	private Schema.SObjectType soType;
	private Boolean enforceCRUD;
	private Boolean enforceFLS;
	private Boolean enforceShr;
    private Set<String> queryFieldsString;
	
	/**
	 * @param sot The SObjectType that the sub-type works with. This parameter should not be defined in sub-types.
	 * @param enforceCRUD The default CRUD enforcement behavior.
	 * @param enforceFLS The default FLS enforcement behavior.
	 * @param enforceShr The default Sharing Rules enforcement behavior.
	 */
	protected Selector(Schema.SObjectType sot, Boolean enforceCRUD, Boolean enforceFLS, Boolean enforceShr, Set<String> queryFieldsString) {
		this.soType			= sot;
		this.enforceCRUD	= enforceCRUD;
		this.enforceFLS		= enforceFLS;
		this.enforceShr		= enforceShr;
        this.queryFieldsString = queryFieldsString;
	}
	/**
	 * This constructor is the same as calling <code>Selector(Schema.SObjectType sot, true, true, true);</code>.
	 */
	protected Selector(Schema.SObjectType sot, Set<String> queryFieldsString) {
		this(sot, true, true, true,queryFieldsString);
	}
	
	/**
	 * @return The SObjectType of the object that this Selector works with.
	 */
	public Schema.SObjectType getSObjectType() {
		return this.soType;
	}
	
	/**
	 * @return The API name of the object that this Selector works with.
	 */
	public String getSObjectName() {
		return this.getSObjectType().getDescribe().getName();
	}
	
	/**
	 * @return true if this Selector should enforce CRUD by default.
	 */
	public Boolean isEnforcingCRUD() {
		return this.enforceCRUD;
	}
	
	/**
	 * @return true if this Selector should enforce FLS by default.
	 */
	public Boolean isEnforcingFLS() {
		return this.enforceFLS;
	}
	
	/**
	 * @return true if this Selector should enforce Sharing Rules by default.
	 */
	public Boolean isEnforcingShr() {
		return this.enforceShr;
	}
    
    /**
	 * @return true if this Selector should enforce Sharing Rules by default.
	 */
	public Set<String> getQueryString() {
		return this.queryFieldsString;
	}

	/**
	 * Builds a SOQL query that uses all the fields passed in. Does not append filters, orders, limits, etc
	 * @param  queryFields String Set of fields
	 * @return             The SQOL query
	 */
	public String getBaseQuery() {
		Set<String> queryFields = getQueryString();
		List<String> fieldList = new List<String>(queryFields);
		String query = String.format('SELECT {0} FROM {1} ', new List<String>{String.join(fieldList, ', '), this.getSObjectName()});
		return query;
	}
}