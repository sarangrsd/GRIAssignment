public class SelectorUtility {
    public static List<SObject> executeQuery(
        String query,
        Boolean enforceCRUD,
        Boolean enforceFLS,
        Boolean enforceSharing,
        Boolean stripInaccessible,
        AccessType accessType
    ) {
        // === Step 1: Normalize query and extract object name and fields ===
        String cleanedQuery = query.trim().replaceAll('\\s+', ' ');
        String upperQuery = cleanedQuery.toUpperCase();

        Integer selectIndex = upperQuery.indexOf('SELECT');
        Integer fromIndex = upperQuery.indexOf('FROM');

        if (selectIndex == -1 || fromIndex == -1 || fromIndex < selectIndex) {
            throw new QueryException('Invalid SOQL query format. Must contain SELECT ... FROM ...');
        }

        String fieldsPart = cleanedQuery.substring(selectIndex + 6, fromIndex).trim();
        String objectPart = cleanedQuery.substring(fromIndex + 4).trim().split(' ')[0]; // Get object name only

        Set<String> fieldNames = new Set<String>();
        for (String field : fieldsPart.split(',')) {
            fieldNames.add(field.trim());
        }

        String objectName = objectPart;

        // === Step 2: Enforce CRUD ===
        if (!stripInaccessible && enforceCRUD) {
            Schema.DescribeSObjectResult describeResult = Schema.getGlobalDescribe().get(objectName).getDescribe();
            if (!describeResult.isAccessible()) {
                throw new AuraHandledException('You do not have access to read ' + objectName + ' records.');
            }
        }

        // === Step 3: Enforce FLS ===
        if (!stripInaccessible && enforceFLS) {
            Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
            for (String fieldName : fieldNames) {
                if (!fieldMap.containsKey(fieldName) || !fieldMap.get(fieldName).getDescribe().isAccessible()) {
                    throw new AuraHandledException('You do not have access to field: ' + fieldName);
                }
            }
        }

        // === Step 4: Run query with correct sharing mode ===
        List<SObject> records;
        if (enforceSharing) {
            records = Database.query(query, AccessLevel.USER_MODE);
        } else {
            records = Database.query(query, AccessLevel.SYSTEM_MODE);
        }

        // === Step 5: Strip inaccessible fields if required ===
        if (stripInaccessible && enforceFLS) {
            SObjectAccessDecision securityDecision = Security.stripInaccessible(accessType, records);
            records = securityDecision.getRecords();
        }

        return records;
    }
}