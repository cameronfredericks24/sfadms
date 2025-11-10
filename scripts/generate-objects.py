#!/usr/bin/env python3
"""Script to generate Salesforce object metadata files"""
import os
import json
from pathlib import Path

BASE_DIR = Path("force-app/main/default/objects")

OBJECTS_CONFIG = {
    "Fund__c": {
        "label": "Fund",
        "fields": [
            ("Promotion__c", "Lookup", {"referenceTo": "Promotion__c"}),
            ("BudgetAmount__c", "Currency", {}),
            ("SpentAmount__c", "Currency", {}),
        ]
    },
    "Commitment__c": {
        "label": "Commitment",
        "fields": [
            ("Fund__c", "Lookup", {"referenceTo": "Fund__c"}),
            ("Account__c", "Lookup", {"referenceTo": "Account"}),
            ("CommittedAmount__c", "Currency", {}),
        ]
    },
    "POSMAsset__c": {
        "label": "POSM Asset",
        "fields": [
            ("Type__c", "Text", {"length": 80}),
            ("Dimensions__c", "Text", {"length": 100}),
            ("MaxLifeDays__c", "Number", {"precision": 5, "scale": 0}),
            ("Status__c", "Picklist", {
                "values": ["InStock", "Issued", "Retired"],
                "defaultValue": "InStock"
            }),
        ]
    },
    "BeatPlan__c": {
        "label": "Beat Plan",
        "fields": [
            ("Month__c", "Date", {}),
            ("Territory__c", "Lookup", {"referenceTo": "Territory2"}),
            ("Owner__c", "Lookup", {"referenceTo": "User"}),
            ("Status__c", "Picklist", {
                "values": ["Draft", "Approved", "Published"],
                "defaultValue": "Draft"
            }),
        ]
    },
    "BeatRoute__c": {
        "label": "Beat Route",
        "masterDetail": "BeatPlan__c",
        "fields": [
            ("Date__c", "Date", {}),
            ("Rep__c", "Lookup", {"referenceTo": "User"}),
            ("StartHub__c", "Text", {"length": 100}),
            ("EndHub__c", "Text", {"length": 100}),
            ("PlannedDoors__c", "Number", {"precision": 5, "scale": 0}),
            ("Status__c", "Picklist", {
                "values": ["Planned", "InProgress", "Completed"],
                "defaultValue": "Planned"
            }),
        ]
    },
    "BeatStop__c": {
        "label": "Beat Stop",
        "masterDetail": "BeatRoute__c",
        "fields": [
            ("Sequence__c", "Number", {"precision": 3, "scale": 0}),
            ("Retailer__c", "Lookup", {"referenceTo": "Account"}),
            ("CheckinWindowStart__c", "DateTime", {}),
            ("CheckinWindowEnd__c", "DateTime", {}),
            ("PlannedActivitiesJSON__c", "LongTextArea", {"length": 32768}),
        ]
    },
    "Visit__c": {
        "label": "Visit",
        "fields": [
            ("Retailer__c", "Lookup", {"referenceTo": "Account", "required": True}),
            ("Rep__c", "Lookup", {"referenceTo": "User", "required": True}),
            ("CheckIn__c", "DateTime", {}),
            ("CheckOut__c", "DateTime", {}),
            ("Latitude__c", "Number", {"precision": 10, "scale": 7}),
            ("Longitude__c", "Number", {"precision": 10, "scale": 7}),
            ("ComplianceScore__c", "Percent", {"precision": 5, "scale": 2}),
            ("Status__c", "Picklist", {
                "values": ["Planned", "InProgress", "Completed", "Skipped"],
                "defaultValue": "Planned"
            }),
            ("SignatureId__c", "Text", {"length": 18}),
            ("Summary__c", "LongTextArea", {"length": 32768}),
        ]
    },
    "Activity__c": {
        "label": "Activity",
        "masterDetail": "Visit__c",
        "fields": [
            ("Type__c", "Picklist", {
                "values": ["OSA", "PriceCheck", "POSM", "Survey", "Collection"],
                "required": True
            }),
            ("ChecklistJSON__c", "LongTextArea", {"length": 32768}),
            ("ResultJSON__c", "LongTextArea", {"length": 32768}),
            ("PhotoIds__c", "LongTextArea", {"length": 32768}),
        ]
    },
    "RetailInventorySnapshot__c": {
        "label": "Retail Inventory Snapshot",
        "fields": [
            ("Visit__c", "Lookup", {"referenceTo": "Visit__c"}),
            ("Product__c", "Lookup", {"referenceTo": "Product2", "required": True}),
            ("OnHandQty__c", "Number", {"precision": 18, "scale": 3}),
            ("ExpiryDate__c", "Date", {}),
        ]
    },
    "PhotoEvidence__c": {
        "label": "Photo Evidence",
        "fields": [
            ("Visit__c", "Lookup", {"referenceTo": "Visit__c"}),
            ("ContentVersionId__c", "Text", {"length": 18}),
            ("LabelsJSON__c", "LongTextArea", {"length": 32768}),
        ]
    },
    "SecondaryOrder__c": {
        "label": "Secondary Order",
        "fields": [
            ("Retailer__c", "Lookup", {"referenceTo": "Account", "required": True}),
            ("Distributor__c", "Lookup", {"referenceTo": "Account", "required": True}),
            ("Visit__c", "Lookup", {"referenceTo": "Visit__c"}),
            ("Status__c", "Picklist", {
                "values": ["Draft", "Confirmed", "Delivered", "Invoiced"],
                "defaultValue": "Draft"
            }),
            ("GrossAmount__c", "Currency", {}),
            ("NetAmount__c", "Currency", {}),
            ("TaxAmount__c", "Currency", {}),
            ("AppliedPromosJSON__c", "LongTextArea", {"length": 32768}),
            ("RequestedDeliveryDate__c", "Date", {}),
            ("ExternalRef__c", "Text", {"length": 80, "externalId": True, "unique": True}),
        ]
    },
    "SecondaryOrderLine__c": {
        "label": "Secondary Order Line",
        "masterDetail": "SecondaryOrder__c",
        "fields": [
            ("Product__c", "Lookup", {"referenceTo": "Product2", "required": True}),
            ("QtyBase__c", "Number", {"precision": 18, "scale": 3}),
            ("QtyDisplay__c", "Text", {"length": 32}),
            ("UoM__c", "Picklist", {
                "values": ["EA", "CS", "PK", "PLT"],
                "required": True
            }),
            ("UnitPrice__c", "Currency", {}),
            ("LineDiscount__c", "Currency", {}),
            ("Tax__c", "Currency", {}),
            ("NetLineAmount__c", "Currency", {}),
            ("PromoLineRef__c", "Text", {"length": 64}),
            ("BatchLot__c", "Lookup", {"referenceTo": "BatchLot__c"}),
        ]
    },
    "PrimaryOrder__c": {
        "label": "Primary Order",
        "fields": [
            ("Distributor__c", "Lookup", {"referenceTo": "Account", "required": True}),
            ("TriggeredBy__c", "Picklist", {
                "values": ["Manual", "Auto"],
                "defaultValue": "Manual"
            }),
            ("Status__c", "Picklist", {
                "values": ["Draft", "Confirmed", "Delivered"],
                "defaultValue": "Draft"
            }),
        ]
    },
    "PrimaryOrderLine__c": {
        "label": "Primary Order Line",
        "masterDetail": "PrimaryOrder__c",
        "fields": [
            ("Product__c", "Lookup", {"referenceTo": "Product2", "required": True}),
            ("Qty__c", "Number", {"precision": 18, "scale": 3}),
            ("UnitCost__c", "Currency", {}),
        ]
    },
    "BatchLot__c": {
        "label": "Batch Lot",
        "fields": [
            ("Product__c", "Lookup", {"referenceTo": "Product2", "required": True}),
            ("LotNo__c", "Text", {"length": 80, "externalId": True, "unique": True, "required": True}),
            ("MfgDate__c", "Date", {}),
            ("ExpiryDate__c", "Date", {}),
            ("QtyOnHand__c", "Number", {"precision": 18, "scale": 3}),
            ("Location__c", "Text", {"length": 100}),
            ("Status__c", "Picklist", {
                "values": ["Available", "Quarantine"],
                "defaultValue": "Available"
            }),
        ]
    },
    "InventoryLedger__c": {
        "label": "Inventory Ledger",
        "fields": [
            ("Distributor__c", "Lookup", {"referenceTo": "Account", "required": True}),
            ("Product__c", "Lookup", {"referenceTo": "Product2", "required": True}),
            ("MovementType__c", "Picklist", {
                "values": ["StockIn", "StockOut", "Adjust"],
                "required": True
            }),
            ("Qty__c", "Number", {"precision": 18, "scale": 3, "required": True}),
            ("UnitCost__c", "Currency", {}),
            ("BatchLot__c", "Lookup", {"referenceTo": "BatchLot__c"}),
            ("RefType__c", "Picklist", {
                "values": ["GRN", "Invoice", "Return", "Adjust"],
                "required": True
            }),
            ("RefId__c", "Text", {"length": 80, "required": True}),
            ("TxnTs__c", "DateTime", {"required": True}),
        ]
    },
    "GRN__c": {
        "label": "GRN",
        "fields": [
            ("PrimaryOrder__c", "Lookup", {"referenceTo": "PrimaryOrder__c"}),
            ("Posted__c", "Checkbox", {"defaultValue": False}),
            ("ScannerSessionId__c", "Text", {"length": 80}),
            ("VarianceJSON__c", "LongTextArea", {"length": 32768}),
        ]
    },
    "GRNLine__c": {
        "label": "GRN Line",
        "masterDetail": "GRN__c",
        "fields": [
            ("Product__c", "Lookup", {"referenceTo": "Product2", "required": True}),
            ("ReceivedQty__c", "Number", {"precision": 18, "scale": 3}),
            ("AcceptedQty__c", "Number", {"precision": 18, "scale": 3}),
            ("DamagedQty__c", "Number", {"precision": 18, "scale": 3}),
            ("BatchLot__c", "Lookup", {"referenceTo": "BatchLot__c"}),
        ]
    },
    "DeliveryNote__c": {
        "label": "Delivery Note",
        "fields": [
            ("SecondaryOrder__c", "Lookup", {"referenceTo": "SecondaryOrder__c"}),
            ("DeliveredAt__c", "DateTime", {}),
            ("Vehicle__c", "Text", {"length": 80}),
            ("Driver__c", "Lookup", {"referenceTo": "User"}),
        ]
    },
    "Invoice__c": {
        "label": "Invoice",
        "fields": [
            ("SecondaryOrder__c", "Lookup", {"referenceTo": "SecondaryOrder__c"}),
            ("Amount__c", "Currency", {}),
            ("Tax__c", "Currency", {}),
            ("PostedAt__c", "DateTime", {}),
        ]
    },
    "AppliedPromotion__c": {
        "label": "Applied Promotion",
        "fields": [
            ("SecondaryOrder__c", "Lookup", {"referenceTo": "SecondaryOrder__c"}),
            ("SecondaryOrderLine__c", "Lookup", {"referenceTo": "SecondaryOrderLine__c"}),
            ("Promotion__c", "Lookup", {"referenceTo": "Promotion__c"}),
            ("Value__c", "Currency", {}),
            ("Basis__c", "Text", {"length": 255}),
            ("ProofRef__c", "Text", {"length": 80}),
        ]
    },
    "PromoAccrual__c": {
        "label": "Promo Accrual",
        "fields": [
            ("Account__c", "Lookup", {"referenceTo": "Account", "required": True}),
            ("Period__c", "Date", {"required": True}),
            ("AccruedAmount__c", "Currency", {}),
            ("SettledAmount__c", "Currency", {}),
        ]
    },
    "Claim__c": {
        "label": "Claim",
        "fields": [
            ("Type__c", "Picklist", {
                "values": ["Promo", "Damage", "Expiry", "Short"],
                "required": True
            }),
            ("BasisRef__c", "Text", {"length": 80}),
            ("Amount__c", "Currency", {"required": True}),
            ("Status__c", "Picklist", {
                "values": ["Draft", "Submitted", "Approved", "Settled"],
                "defaultValue": "Draft"
            }),
            ("Distributor__c", "Lookup", {"referenceTo": "Account"}),
            ("Retailer__c", "Lookup", {"referenceTo": "Account"}),
            ("ApprovalStage__c", "Text", {"length": 50}),
        ]
    },
    "ClaimEvidence__c": {
        "label": "Claim Evidence",
        "masterDetail": "Claim__c",
        "fields": [
            ("ContentVersionId__c", "Text", {"length": 18}),
            ("Notes__c", "LongTextArea", {"length": 32768}),
        ]
    },
    "ReplenishmentPolicy__c": {
        "label": "Replenishment Policy",
        "fields": [
            ("Distributor__c", "Lookup", {"referenceTo": "Account", "required": True}),
            ("Product__c", "Lookup", {"referenceTo": "Product2", "required": True}),
            ("MinQty__c", "Number", {"precision": 18, "scale": 3}),
            ("MaxQty__c", "Number", {"precision": 18, "scale": 3}),
            ("DaysCover__c", "Number", {"precision": 5, "scale": 0}),
            ("SafetyStock__c", "Number", {"precision": 18, "scale": 3}),
            ("LeadTimeDays__c", "Number", {"precision": 5, "scale": 0}),
            ("AutoFlag__c", "Checkbox", {"defaultValue": False}),
        ]
    },
    "ReplenishmentProposal__c": {
        "label": "Replenishment Proposal",
        "fields": [
            ("Distributor__c", "Lookup", {"referenceTo": "Account", "required": True}),
            ("Product__c", "Lookup", {"referenceTo": "Product2", "required": True}),
            ("ProposedQty__c", "Number", {"precision": 18, "scale": 3}),
            ("BasisJSON__c", "LongTextArea", {"length": 32768}),
            ("ConvertedToPrimary__c", "Checkbox", {"defaultValue": False}),
        ]
    },
}

PLATFORM_EVENTS = {
    "OrderSubmittedEvent__e": {
        "label": "Order Submitted Event",
        "fields": [
            ("OrderId__c", "Text", {"length": 18, "required": True}),
            ("RetailerId__c", "Text", {"length": 18}),
            ("DistributorId__c", "Text", {"length": 18}),
            ("PayloadJSON__c", "LongTextArea", {"length": 32768}),
        ]
    },
    "GRNPostedEvent__e": {
        "label": "GRN Posted Event",
        "fields": [
            ("GrnId__c", "Text", {"length": 18, "required": True}),
            ("PrimaryOrderId__c", "Text", {"length": 18}),
            ("PayloadJSON__c", "LongTextArea", {"length": 32768}),
        ]
    },
    "ClaimRaisedEvent__e": {
        "label": "Claim Raised Event",
        "fields": [
            ("ClaimId__c", "Text", {"length": 18, "required": True}),
            ("PayloadJSON__c", "LongTextArea", {"length": 32768}),
        ]
    },
}

def generate_field_xml(field_name, field_type, config, object_name):
    """Generate field metadata XML"""
    xml = f'<?xml version="1.0" encoding="UTF-8"?>\n'
    xml += '<CustomField xmlns="http://www.salesforce.com/2006/04/metadata">\n'
    xml += f'    <fullName>{field_name}</fullName>\n'
    
    if field_type == "Lookup":
        xml += f'    <externalId>false</externalId>\n'
        xml += f'    <label>{field_name.replace("__c", "").replace("_", " ")}</label>\n'
        xml += f'    <referenceTo>{config.get("referenceTo")}</referenceTo>\n'
        if config.get("required"):
            xml += '    <required>true</required>\n'
        xml += '    <relationshipLabel>Related Records</relationshipLabel>\n'
        xml += '    <relationshipName>Related_Records</relationshipName>\n'
        xml += '    <relationshipOrder>0</relationshipOrder>\n'
        xml += '    <reparentableMasterDetail>false</reparentableMasterDetail>\n'
        xml += '    <trackFeedHistory>false</trackFeedHistory>\n'
        xml += '    <trackHistory>false</trackHistory>\n'
        xml += '    <trackTrending>false</trackTrending>\n'
        xml += '    <type>Lookup</type>\n'
        xml += '    <writeRequiresMasterRead>false</writeRequiresMasterRead>\n'
    elif field_type == "Currency":
        xml += '    <externalId>false</externalId>\n'
        xml += f'    <label>{field_name.replace("__c", "").replace("_", " ")}</label>\n'
        xml += '    <precision>18</precision>\n'
        if config.get("required"):
            xml += '    <required>true</required>\n'
        else:
            xml += '    <required>false</required>\n'
        xml += '    <scale>2</scale>\n'
        xml += '    <trackFeedHistory>true</trackFeedHistory>\n'
        xml += '    <trackHistory>true</trackHistory>\n'
        xml += '    <trackTrending>false</trackTrending>\n'
        xml += '    <type>Currency</type>\n'
    elif field_type == "Number":
        xml += '    <externalId>false</externalId>\n'
        xml += f'    <label>{field_name.replace("__c", "").replace("_", " ")}</label>\n'
        xml += f'    <precision>{config.get("precision", 18)}</precision>\n'
        if config.get("required"):
            xml += '    <required>true</required>\n'
        else:
            xml += '    <required>false</required>\n'
        xml += f'    <scale>{config.get("scale", 0)}</scale>\n'
        xml += '    <trackFeedHistory>true</trackFeedHistory>\n'
        xml += '    <trackHistory>true</trackHistory>\n'
        xml += '    <trackTrending>false</trackTrending>\n'
        xml += '    <type>Number</type>\n'
        xml += '    <unique>false</unique>\n'
    elif field_type == "Text":
        xml += '    <externalId>false</externalId>\n'
        xml += f'    <label>{field_name.replace("__c", "").replace("_", " ")}</label>\n'
        xml += f'    <length>{config.get("length", 255)}</length>\n'
        if config.get("required"):
            xml += '    <required>true</required>\n'
        else:
            xml += '    <required>false</required>\n'
        if config.get("externalId"):
            xml += '    <externalId>true</externalId>\n'
        if config.get("unique"):
            xml += '    <unique>true</unique>\n'
        xml += '    <trackFeedHistory>false</trackFeedHistory>\n'
        xml += '    <trackHistory>false</trackHistory>\n'
        xml += '    <trackTrending>false</trackTrending>\n'
        xml += '    <type>Text</type>\n'
        xml += '    <unique>false</unique>\n'
    elif field_type == "LongTextArea":
        xml += '    <externalId>false</externalId>\n'
        xml += f'    <label>{field_name.replace("__c", "").replace("_", " ")}</label>\n'
        xml += f'    <length>{config.get("length", 32768)}</length>\n'
        if config.get("required"):
            xml += '    <required>true</required>\n'
        else:
            xml += '    <required>false</required>\n'
        xml += '    <trackFeedHistory>false</trackFeedHistory>\n'
        xml += '    <trackHistory>false</trackHistory>\n'
        xml += '    <trackTrending>false</trackTrending>\n'
        xml += '    <type>LongTextArea</type>\n'
        xml += '    <visibleLines>5</visibleLines>\n'
    elif field_type == "Picklist":
        xml += '    <externalId>false</externalId>\n'
        xml += f'    <label>{field_name.replace("__c", "").replace("_", " ")}</label>\n'
        if config.get("required"):
            xml += '    <required>true</required>\n'
        else:
            xml += '    <required>false</required>\n'
        xml += '    <trackFeedHistory>true</trackFeedHistory>\n'
        xml += '    <trackHistory>true</trackHistory>\n'
        xml += '    <trackTrending>false</trackTrending>\n'
        xml += '    <type>Picklist</type>\n'
        xml += '    <valueSet>\n'
        xml += '        <restrictedPicklist>true</restrictedPicklist>\n'
        xml += '        <valueSetDefinition>\n'
        xml += '            <sorted>false</sorted>\n'
        for value in config.get("values", []):
            xml += f'            <value>\n'
            xml += f'                <fullName>{value}</fullName>\n'
            xml += f'                <default>{value == config.get("defaultValue", "")}</default>\n'
            xml += f'                <label>{value}</label>\n'
            xml += f'            </value>\n'
        xml += '        </valueSetDefinition>\n'
        xml += '    </valueSet>\n'
    elif field_type == "Checkbox":
        xml += f'    <defaultValue>{str(config.get("defaultValue", False)).lower()}</defaultValue>\n'
        xml += '    <externalId>false</externalId>\n'
        xml += f'    <label>{field_name.replace("__c", "").replace("_", " ")}</label>\n'
        xml += '    <trackFeedHistory>true</trackFeedHistory>\n'
        xml += '    <trackHistory>true</trackHistory>\n'
        xml += '    <trackTrending>false</trackTrending>\n'
        xml += '    <type>Checkbox</type>\n'
    elif field_type == "Date":
        xml += '    <externalId>false</externalId>\n'
        xml += f'    <label>{field_name.replace("__c", "").replace("_", " ")}</label>\n'
        if config.get("required"):
            xml += '    <required>true</required>\n'
        else:
            xml += '    <required>false</required>\n'
        xml += '    <trackFeedHistory>true</trackFeedHistory>\n'
        xml += '    <trackHistory>true</trackHistory>\n'
        xml += '    <trackTrending>false</trackTrending>\n'
        xml += '    <type>Date</type>\n'
    elif field_type == "DateTime":
        xml += '    <externalId>false</externalId>\n'
        xml += f'    <label>{field_name.replace("__c", "").replace("_", " ")}</label>\n'
        if config.get("required"):
            xml += '    <required>true</required>\n'
        else:
            xml += '    <required>false</required>\n'
        xml += '    <trackFeedHistory>true</trackFeedHistory>\n'
        xml += '    <trackHistory>true</trackHistory>\n'
        xml += '    <trackTrending>false</trackTrending>\n'
        xml += '    <type>DateTime</type>\n'
    elif field_type == "Percent":
        xml += '    <externalId>false</externalId>\n'
        xml += f'    <label>{field_name.replace("__c", "").replace("_", " ")}</label>\n'
        xml += f'    <precision>{config.get("precision", 5)}</precision>\n'
        if config.get("required"):
            xml += '    <required>true</required>\n'
        else:
            xml += '    <required>false</required>\n'
        xml += f'    <scale>{config.get("scale", 2)}</scale>\n'
        xml += '    <trackFeedHistory>true</trackFeedHistory>\n'
        xml += '    <trackHistory>true</trackHistory>\n'
        xml += '    <trackTrending>false</trackTrending>\n'
        xml += '    <type>Percent</type>\n'
    
    xml += '</CustomField>\n'
    return xml

def generate_object_xml(object_name, config, is_platform_event=False):
    """Generate object metadata XML"""
    label = config["label"]
    plural_label = label + "s" if not label.endswith("s") else label
    
    xml = '<?xml version="1.0" encoding="UTF-8"?>\n'
    if is_platform_event:
        xml += '<CustomObject xmlns="http://www.salesforce.com/2006/04/metadata" xsi:type="CustomObject">\n'
        xml += '    <deploymentStatus>Deployed</deploymentStatus>\n'
        xml += f'    <label>{label}</label>\n'
        xml += f'    <pluralLabel>{plural_label}</pluralLabel>\n'
        xml += '    <publishBehavior>PublishAfterCreate</publishBehavior>\n'
    else:
        xml += '<CustomObject xmlns="http://www.salesforce.com/2006/04/metadata">\n'
        xml += '    <actionOverrides>\n'
        xml += '        <actionName>Accept</actionName>\n'
        xml += '        <type>Default</type>\n'
        xml += '    </actionOverrides>\n'
        xml += '    <actionOverrides>\n'
        xml += '        <actionName>CancelEdit</actionName>\n'
        xml += '        <type>Default</type>\n'
        xml += '    </actionOverrides>\n'
        xml += '    <actionOverrides>\n'
        xml += '        <actionName>Clone</actionName>\n'
        xml += '        <type>Default</type>\n'
        xml += '    </actionOverrides>\n'
        xml += '    <actionOverrides>\n'
        xml += '        <actionName>Delete</actionName>\n'
        xml += '        <type>Default</type>\n'
        xml += '    </actionOverrides>\n'
        xml += '    <actionOverrides>\n'
        xml += '        <actionName>Edit</actionName>\n'
        xml += '        <type>Default</type>\n'
        xml += '    </actionOverrides>\n'
        xml += '    <actionOverrides>\n'
        xml += '        <actionName>List</actionName>\n'
        xml += '        <type>Default</type>\n'
        xml += '    </actionOverrides>\n'
        xml += '    <actionOverrides>\n'
        xml += '        <actionName>New</actionName>\n'
        xml += '        <type>Default</type>\n'
        xml += '    </actionOverrides>\n'
        xml += '    <actionOverrides>\n'
        xml += '        <actionName>SaveEdit</actionName>\n'
        xml += '        <type>Default</type>\n'
        xml += '    </actionOverrides>\n'
        xml += '    <actionOverrides>\n'
        xml += '        <actionName>Tab</actionName>\n'
        xml += '        <type>Default</type>\n'
        xml += '    </actionOverrides>\n'
        xml += '    <actionOverrides>\n'
        xml += '        <actionName>View</actionName>\n'
        xml += '        <type>Default</type>\n'
        xml += '    </actionOverrides>\n'
        xml += '    <allowInChatterGroups>false</allowInChatterGroups>\n'
        xml += '    <compactLayoutAssignment>SYSTEM</compactLayoutAssignment>\n'
        xml += '    <deploymentStatus>Deployed</deploymentStatus>\n'
        xml += '    <enableActivities>true</enableActivities>\n'
        xml += '    <enableBulkApi>true</enableBulkApi>\n'
        xml += '    <enableChangeDataCapture>false</enableChangeDataCapture>\n'
        xml += '    <enableFeeds>false</enableFeeds>\n'
        xml += '    <enableHistory>true</enableHistory>\n'
        xml += '    <enableLicensing>false</enableLicensing>\n'
        xml += '    <enableReports>true</enableReports>\n'
        xml += '    <enableSearch>true</enableSearch>\n'
        xml += '    <enableSharing>true</enableSharing>\n'
        xml += '    <enableStreamingApi>true</enableStreamingApi>\n'
        xml += '    <externalSharingModel>Private</externalSharingModel>\n'
        xml += f'    <label>{label}</label>\n'
        
        if config.get("masterDetail"):
            xml += f'    <masterDetail>\n'
            xml += f'        <masterLabel>{config["masterDetail"]}</masterLabel>\n'
            xml += f'        <relationshipLabel>{plural_label}</relationshipLabel>\n'
            xml += f'        <relationshipName>{plural_label.replace(" ", "_")}</relationshipName>\n'
            xml += f'    </masterDetail>\n'
        else:
            xml += '    <nameField>\n'
            xml += f'        <label>{label} Name</label>\n'
            xml += '        <type>Text</type>\n'
            xml += '    </nameField>\n'
        
        xml += f'    <pluralLabel>{plural_label}</pluralLabel>\n'
        xml += '    <searchStatus>Inactive</searchStatus>\n'
        xml += '    <sharingModel>ReadWrite</sharingModel>\n'
        xml += '    <visibility>Public</visibility>\n'
    
    xml += '</CustomObject>\n'
    return xml

def main():
    """Generate all object metadata files"""
    BASE_DIR.mkdir(parents=True, exist_ok=True)
    
    # Generate custom objects
    for object_name, config in OBJECTS_CONFIG.items():
        obj_dir = BASE_DIR / object_name
        obj_dir.mkdir(parents=True, exist_ok=True)
        fields_dir = obj_dir / "fields"
        fields_dir.mkdir(parents=True, exist_ok=True)
        
        # Generate object XML
        object_xml = generate_object_xml(object_name, config)
        object_file = obj_dir / f"{object_name}.object-meta.xml"
        object_file.write_text(object_xml)
        
        # Generate field XMLs
        for field_name, field_type, field_config in config["fields"]:
            field_xml = generate_field_xml(field_name, field_type, field_config, object_name)
            field_file = fields_dir / f"{field_name}.field-meta.xml"
            field_file.write_text(field_xml)
    
    # Generate platform events
    for event_name, config in PLATFORM_EVENTS.items():
        event_dir = BASE_DIR / event_name
        event_dir.mkdir(parents=True, exist_ok=True)
        fields_dir = event_dir / "fields"
        fields_dir.mkdir(parents=True, exist_ok=True)
        
        # Generate event XML
        event_xml = generate_object_xml(event_name, config, is_platform_event=True)
        event_file = event_dir / f"{event_name}.object-meta.xml"
        event_file.write_text(event_xml)
        
        # Generate field XMLs
        for field_name, field_type, field_config in config["fields"]:
            field_xml = generate_field_xml(field_name, field_type, field_config, event_name)
            field_file = fields_dir / f"{field_name}.field-meta.xml"
            field_file.write_text(field_xml)
    
    print("Generated all object metadata files")

if __name__ == "__main__":
    main()
