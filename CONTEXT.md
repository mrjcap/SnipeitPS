# SnipeitPS Domain Model

The domain model and terms for SnipeitPS and the Snipe-IT REST API.

## Terms

**Hardware Asset**:
An individually tracked physical item identified by an asset tag or serial number.
_Avoid_: Device, machine, inventory item

**Component**:
A modular item installed inside an asset (e.g. RAM, hard drive) that cannot be checked out directly to a user.
_Avoid_: Part, sub-asset, piece

**Accessory**:
A physical item issued to users without unique serial numbers, tracked in bulk quantities.
_Avoid_: Peripheral, hardware item, tool

**Consumable**:
A supply item consumed upon issue that cannot be checked back in (e.g. toner, cables).
_Avoid_: Supply, inventory stock

**License Seat**:
An individual slot of a software license allocated to a user or asset.
_Avoid_: License key, software entitlement

**Fieldset**:
A group of custom fields attached to a model to store domain-specific values.
_Avoid_: Field group, schema definition
