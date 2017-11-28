/**
 * Created by chshah on 11/22/2017.
 */

public without sharing class RatingController {

    /**
     * get rates
     *
     * @param fromLine1
     * @param fromCity
     * @param fromState
     * @param fromZip
     * @param fromCountry
     * @param toLine1
     * @param toCity
     * @param toState
     * @param toZip
     * @param toCountry
     * @param weight
     *
     * @return
     */

    @RemoteAction
    public static List<Rate> getRates(String fromLine1, String fromCity, String fromState, String fromZip, String fromCountry,
            String toLine1, String toCity, String toState, String toZip, String toCountry, Integer weight) {
        FedExWrapperService.ShipAddress fromAddress = new FedExWrapperService.ShipAddress(fromLine1, null, fromCity, fromState, fromZip, fromCountry);
        FedExWrapperService.ShipAddress toAddress = new FedExWrapperService.ShipAddress(toLine1, null, toCity, toState, toZip, toCountry);
        List<Rate> rates = FedExWrapperService.getRate(fromAddress, toAddress, weight);
        return rates;
    }

}