FedExWrapperService.ShipAddress toAddress = new FedExWrapperService.ShipAddress();
FedExWrapperService.ShipAddress fromAddress = new FedExWrapperService.ShipAddress();
toAddress.line1='1030 Harvard St';
toAddress.city='Santa Monica';
toAddress.state='CA';
toAddress.zip='90403';
toAddress.country='US';
fromAddress.line1='1034 Harvard St';
fromAddress.city='Santa Monica';
fromAddress.state='CA';
fromAddress.zip='90403';
fromAddress.country='US';
FedExWrapperService.getRate(fromAddress, toAddress, 10);