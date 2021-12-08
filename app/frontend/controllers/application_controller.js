import {Controller} from "stimulus"

export class ApplicationController extends Controller {

    // getControllerByIdentifier(identifier) {
    //     return this.application.controllers.find(controller => {
    //         return controller.context.identifier === identifier;
    //     });
    // }

    getControllerNames() {
        const controllers =  this.application.controllers.map(controller => {
            return controller.context.identifier;
        });

        return [... new Set(controllers)]
    }

}