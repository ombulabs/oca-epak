# oca-epak
Ruby Wrapper for OCA e-Pak API

[![Gem Version](https://badge.fury.io/rb/oca-epak.svg)](http://badge.fury.io/rb/oca-epak)
[![Build Status](https://travis-ci.org/ombulabs/oca-epak.svg?branch=master)](https://travis-ci.org/ombulabs/oca-epak)
[![Code Climate](https://codeclimate.com/github/ombulabs/oca-epak/badges/gpa.svg)](https://codeclimate.com/github/ombulabs/oca-epak)

## Getting Started

For command line usage:

```bash
$ gem install oca-epak
```

If you intend to use it within an application, add `gem "oca-epak"` to your
`Gemfile`.

## Usage

There are two OCA clients available, one for each endpoint. `Oca::Epak::Client`
provides most of OCA's Epak offerings. The other one, which uses an older
endpoint, `Oca::Oep::Client`, provides only a few methods which aren't yet
available under the new endpoint.

You will most likely want to use `Oca::Epak::Client` most of the time. To
initialize a client:

```ruby
epak_client = Oca::Epak::Client.new("your-email@example.com", "your-password")
```

To check whether your credentials are valid or not, run `#check_credentials`

```ruby
epak_client.check_credentials
=> true
```

To see your available operation codes, you can use `#get_operation_codes`

```ruby
operation_codes = epak_client.get_operation_codes
=> [{ :id_operativa=>"77790",
      :descripcion=>"77790 - ENVIOS DE PUERTA A PUERTA",
      :con_volumen=>false,
      :con_valor_declarado=>false,
      :a_sucursal=>false,
      :"@diffgr:id"=>"Table1",
      :"@msdata:row_order"=>"0" }]
```

NOTE: Keep in mind that you cannot register/create an operation code via OCA's
API, you have to get in touch with someone from OCA and they take care of the
registration.

After you have your operation code active for a given delivery type, you can
begin calculating shipping rates and delivery estimates:

```ruby
opts = { total_weight: "50", total_volume: "0.027", origin_zip_code: "1646",
         destination_zip_code: "2000", declared_value: "100",
         package_quantity: "1", cuit: "30-99999999-7", operation_code: "77790" }

epak_client.get_shipping_rate(opts)
=> {:tarifador=>"15",
    :precio=>"328.9000",
    :id_tiposervicio=>"2",
    :ambito=>"Regional",
    :plazo_entrega=>"3",
    :adicional=>"0.0000",
    :total=>"328.9000",
    :xml=>"<row Tarifador=\"15\" Precio=\"328.9000\"/>",
    :"@diffgr:id"=>"Table1",
    :"@msdata:row_order"=>"0"}
```

To create a pickup order, in order to let OCA know that they should pick up an
order for delivery, you can use `#create_pickup_order`.

You will first need to create an `Oca::Epak::PickupData` object.
The pickup hash contains information about the sender of the package, where OCA
should pick it up. The shipments hash contains information about who will
receive the package, where it should be sent:

```ruby
opts = {
  account_number: "your-account-number-aka-sap",
  pickup: { "calle" => "street-name",
            "numero" => "street-number",
            "piso" => "",
            "departamento" => "",
            "cp" => "zipcode",
            "localidad" => "city",
            "provincia" => "province",
            "solicitante" => "your-name",
            "email" => "your-email",
            "observaciones"=> "" },
  shipments: [
    {
      "id_operativa" => "operation-code",
      "numero_remito" => "your-internal-order-number",
      "destinatario" => {
        "apellido" => "last-name",
        "nombre" => "first-name",
        "calle" => "street-name",
        "numero" => "street-number",
        "piso" => "",
        "departamento" => "",
        "cp" => "zipcode",
        "localidad" => "city",
        "provincia" => "provice",
        "telefono" => "phone",
        "email" => "email"
      },
      "paquetes"=> [
        {
          "alto" => "package-height-in-m",
          "ancho" => "package-width-in-m",
          "largo" => "package-depth-in-m",
          "peso" => "package-weight-in-kg",
          "valor_declarado" => "package-monetary-value",
          "cantidad" => "quantity-of-packages"
        }
      ]
    }
  ]
}

pickup_data = Oca::Epak::PickupData.new(opts)
```

After you create the `PickupData` object, you can submit the shipment:

```ruby
response = epak_client.create_pickup_order(pickup_data)
response[:diffgram]
=> {:resultado=>
    {:resumen=>
      {:codigo_operacion=>"13150502",
       :fecha_ingreso=>#<DateTime: 2015-11-17T11:43:50-03:00 ((2457344j,53030s,607000000n),-10800s,2299161j)>,
       :mail_usuario=>"hola@ombushop.com",
       :cantidad_registros=>"1",
       :cantidad_ingresados=>"1",
       :cantidad_rechazados=>"0",
       :"@diffgr:id"=>"Resumen1",
       :"@msdata:row_order"=>"0"}
     }
   }
```

`#create_pickup_order` has a few extra options you can check by browsing the
[method's documentation](http://www.rubydoc.info/github/ombulabs/oca-epak/master/Oca%2FEpak%2FClient%3Acreate_pickup_order).

## Contributing & Development

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Write your feature (and tests)
4. Run tests (`bundle exec rake`)
5. Commit your changes (`git commit -am 'Added some feature'`)
6. Push to the branch (`git push origin my-new-feature`)
7. Create new Pull Request

## Release the Gem

```bash
$ bundle exec rake release
```
