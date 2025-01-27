unit DZhTypes;

interface

type
  TUser = record
    PersonalCode: string;
    FirstName: string;
    LastName: string;
    Country: string;
    County: string;
    AdministrativeUnit: string;
    SettlementUnit: string;
    Street: string;
    House: string;
    Apartment: string;
    PostalCode: string;
    Phone: string;
  end;

type
  TValidatorFunc = function(const Value: string; out ErrorMessage: string): Boolean of object;

const
  ColumnNames: array [0 .. 11] of string = (
  'Personal Code',
  'First Name', 'Last Name',
  'Country', 'County', 'Administrative unit', 'Settlement unit', 'Street', 'House', 'Apartment', 'Postal Code',
  'Phone');

implementation

end.
