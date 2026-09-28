@Observed
export class Location{
  positionX:number
  positionY:number
  oripositionX:number
  oripositionY:number
  constructor(
    positionX:number,
    positionY:number,
    ) {
    this.positionX=positionX
    this.positionY=positionY
    this.oripositionX=this.positionX
    this.oripositionY=this.positionY
  }
}

export class AddressItem{
  name?:Resource
  icon?:Resource
  location?:Array<Location>=[]
  textColor?:Resource


}