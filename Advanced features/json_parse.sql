--we suggest to not use json data objects as strings when setting up your event structure. However some parameters, such as the google transactonReceipt are json strings anyway.
--Vertica is able to extract a map object from the json string and with maplookup you are able to retrieve the value for the selected key.
select 
        maplookup(MapJSONExtractor(transactionReceipt), 'packageName') as PackageName,
        transactionReceipt
from events 
where transactionServer = 'GOOGLE' 
and revenueValidated = 1
