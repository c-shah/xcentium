/**
 * Created by chshah on 11/21/2017.
 */

public without sharing class FedExWrapperService {

    public class ShipAddress {
        public String line1 {get; set;}
        public String line2  {get; set;}
        public String city  {get; set;}
        public String state  {get; set;}
        public String zip  {get; set;}
        public String country  {get; set;}
        public ShipAddress(String line1, String line2, String city, String state, String zip, String country) {
            this.line1 = line1;
            this.line2 = line2;
            this.city = city;
            this.state = state;
            this.zip = zip;
            this.country = country;
        }
    }

    public enum SERVICE_TYPES {
        EUROPE_FIRST_INTERNATIONAL_PRIORITY,
        FEDEX_1_DAY_FREIGHT,
        FEDEX_2_DAY,
        FEDEX_2_DAY_AM,
        FEDEX_2_DAY_FREIGHT,
        FEDEX_3_DAY_FREIGHT,
        FEDEX_DISTANCE_DEFERRED,
        FEDEX_EXPRESS_SAVER,
        FEDEX_FIRST_FREIGHT,
        FEDEX_FREIGHT_ECONOMY,
        FEDEX_FREIGHT_PRIORITY,
        FEDEX_GROUND,
        FEDEX_NEXT_DAY_AFTERNOON,
        FEDEX_NEXT_DAY_EARLY_MORNING,
        FEDEX_NEXT_DAY_END_OF_DAY,
        FEDEX_NEXT_DAY_FREIGHT,
        FEDEX_NEXT_DAY_MID_MORNING,
        FIRST_OVERNIGHT,
        GROUND_HOME_DELIVERY,
        INTERNATIONAL_ECONOMY,
        INTERNATIONAL_ECONOMY_FREIGHT,
        INTERNATIONAL_FIRST,
        INTERNATIONAL_PRIORITY,
        INTERNATIONAL_PRIORITY_EXPRESS,
        INTERNATIONAL_PRIORITY_FREIGHT,
        PRIORITY_OVERNIGHT,
        SAME_DAY,
        SAME_DAY_CITY,
        SMART_POST,
        STANDARD_OVERNIGHT
    }

    public static List<Rate> getRate(ShipAddress fromAddress, ShipAddress toAddress, Integer weightInPound) {
        List<Rate> rates = new List<Rate>();
        for(SERVICE_TYPES serviceType : SERVICE_TYPES.values() ) {
            try {
                Rate rate = getRate(fromAddress, toAddress, weightInPound, String.valueOf(serviceType) );
                if( rate.isError ) {
                    System.debug(' Error with service type ' + String.valueOf(serviceType)  + ' message ' + rate.message );
                    rates.add( rate );
                } else {
                    rates.add( rate );
                }
            } catch(Exception e) {
                Rate currentRate = new Rate();
                currentRate.isError = true;
                currentRate.message = e.getMessage();
                currentRate.serviceType = String.valueOf(serviceType);
                currentRate.amount = null;
                rates.add( currentRate );
                System.debug(' Exception with service type ' + String.valueOf(serviceType)  + ' message ' + e.getMessage() );
            }
        }
        System.debug(' ------------- Successful Rates -------------');
        for(Rate currentRate : rates ) {
            System.debug( currentRate.serviceType + ' ' + currentRate.amount );
        }
        return rates;
    }

    public static Rate getRate(ShipAddress fromAddress, ShipAddress toAddress, Integer weightInPound, String serviceType) {
        try {
            FedexConfiguration__c fedexConfiguration = FedexConfiguration__c.getInstance('default');
            FedExRatingService.RateServicePort ratingService = new FedExRatingService.RateServicePort();

            FedExRatingService.WebAuthenticationDetail webAuthenticationDetail = new FedExRatingService.WebAuthenticationDetail();
            FedExRatingService.WebAuthenticationCredential userCredential = new FedExRatingService.WebAuthenticationCredential();
            webAuthenticationDetail.UserCredential = userCredential;
            userCredential.Key = fedexConfiguration.DeveloperKey__c;
            userCredential.Password = fedexConfiguration.Password__c;

            FedExRatingService.ClientDetail clientDetail = new FedExRatingService.ClientDetail();
            clientDetail.AccountNumber = fedexConfiguration.AccountNumber__c;
            clientDetail.MeterNumber = fedexConfiguration.MeterNumber__c;

            FedExRatingService.TransactionDetail transactionDetail = new FedExRatingService.TransactionDetail();
            transactionDetail.CustomerTransactionId = 'US_PRIORITY_OVERNIGHTwithYourPackaging';

            FedExRatingService.VersionId version = new FedExRatingService.VersionId();
            version.ServiceId = 'crs';
            version.Major = 22;
            version.Intermediate = 0;
            version.Minor = 0;

            Boolean returnTransitAndCommit = false;
            String[] carrierCodes = new List<String>();
            String[] variableOptions = new List<String>();
            FedExRatingService.ConsolidationKey consolidationKey = new FedExRatingService.ConsolidationKey();

            FedExRatingService.RequestedShipment requestedShipment = new FedExRatingService.RequestedShipment();
            requestedShipment.ShipTimestamp = System.now();
            requestedShipment.DropoffType = 'REGULAR_PICKUP';
            requestedShipment.ServiceType = serviceType;
            FedExRatingService.Weight totalWeight = new FedExRatingService.Weight();
            requestedShipment.totalWeight = totalWeight;
            totalWeight.Units = 'LB';
            totalWeight.Value = weightInPound;
            FedExRatingService.Party shipper = new FedExRatingService.Party();
            FedExRatingService.Contact shipperContact = new FedExRatingService.Contact();
            FedExRatingService.Address shipperAddress = new FedExRatingService.Address();
            FedExRatingService.Party recipient = new FedExRatingService.Party();
            FedExRatingService.Contact recipientContact = new FedExRatingService.Contact();
            FedExRatingService.Address recipientAddress = new FedExRatingService.Address();
            requestedShipment.Shipper = shipper;
            requestedShipment.Recipient = recipient;
            shipper.contact = shipperContact;
            shipper.address = shipperAddress;
            recipient.contact = recipientContact;
            recipient.address = recipientAddress;
            shipperContact.CompanyName = 'Shipper';
            shipperContact.PhoneNumber = 'Shipper Phone';
            recipientContact.CompanyName = 'Recipient';
            recipientContact.PhoneNumber = 'Recipient Phone';
            shipperAddress.StreetLines = new List<String> { fromAddress.line1 };
            shipperAddress.City = fromAddress.city;
            shipperAddress.StateOrProvinceCode = fromAddress.state;
            shipperAddress.PostalCode = fromAddress.zip;
            shipperAddress.CountryCode = fromAddress.country;
            recipientAddress.StreetLines = new List<String> { toAddress.line1 };
            recipientAddress.City = toAddress.city;
            recipientAddress.StateOrProvinceCode = toAddress.state;
            recipientAddress.PostalCode = toAddress.zip;
            recipientAddress.CountryCode = toAddress.country;
            FedExRatingService.Payment shippingChargesPayment = new FedExRatingService.Payment();
            FedExRatingService.Payor payor = new FedExRatingService.Payor();
            FedExRatingService.Party responsibleParty = new FedExRatingService.Party();
            shippingChargesPayment.payor = payor;
            shippingChargesPayment.PaymentType = 'SENDER';
            payor.responsibleParty = responsibleParty;
            responsibleParty.AccountNumber = fedexConfiguration.AccountNumber__c;
            requestedShipment.shippingChargesPayment = shippingChargesPayment;
            requestedShipment.RateRequestTypes = new List<String> { 'LIST' } ;
            requestedShipment.PackageCount = 1;
            FedExRatingService.RequestedPackageLineItem requestedPackageLineItem = new FedExRatingService.RequestedPackageLineItem();
            requestedShipment.requestedPackageLineItems = new List<FedExRatingService.RequestedPackageLineItem> { requestedPackageLineItem };
            requestedPackageLineItem.SequenceNumber = 1;
            requestedPackageLineItem.GroupNumber = 1;
            requestedPackageLineItem.GroupPackageCount = 1;
            FedExRatingService.Weight itemWeight = new FedExRatingService.Weight();
            FedExRatingService.Dimensions itemDimensions = new FedExRatingService.Dimensions();
            FedExRatingService.ContentRecord contentRecord = new FedExRatingService.ContentRecord();
            requestedPackageLineItem.weight = itemWeight;
            requestedPackageLineItem.dimensions = itemDimensions;
            requestedPackageLineItem.contentRecords = new List<FedExRatingService.ContentRecord> { contentRecord };
            itemWeight.units = 'LB';
            itemWeight.value = weightInPound;
            itemDimensions.length = 5;
            itemDimensions.Width = 5;
            itemDimensions.Height = 5;
            itemDimensions.Units = 'IN';
            contentRecord.PartNumber = '12345';
            contentRecord.PartNumber = '12345';
            contentRecord.ItemNumber = 'kjdjalsro1262739827';
            contentRecord.ReceivedQuantity = 1;
            contentRecord.Description = 'ContentDescription';

            FedExRatingService.RateReply rateReply = ratingService.getRates(webAuthenticationDetail, clientDetail, transactionDetail, version, returnTransitAndCommit, carrierCodes, variableOptions, consolidationKey, requestedShipment);
            // System.debug(' rateReply ' + rateReply );
            return convertRateReplyToRate(rateReply, serviceType);
        } catch(Exception e) {
            System.debug(LoggingLevel.ERROR, e + e.getStackTraceString() );
            throw e;
        }
    }

    private static Rate convertRateReplyToRate(FedExRatingService.RateReply rateReply, String serviceType) {
        Rate currentRate = new Rate();
        if( rateReply.HighestSeverity == 'SUCCESS' ) {
            currentRate.isError = false;
            currentRate.message = rateReply.Notifications.get(0).Message;
            currentRate.serviceType = rateReply.RateReplyDetails.get(0).ServiceType;
            currentRate.amount = RateReply.RateReplyDetails.get(0).RatedShipmentDetails.get(0).RatedPackages.get(0).PackageRateDetail.NetCharge.Amount;
        } else {
            currentRate.isError = true;
            currentRate.message = rateReply.Notifications.get(0).Message;
            currentRate.serviceType = serviceType;
        }
        return currentRate;
    }

}