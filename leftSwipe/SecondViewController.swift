//
//  SecondViewController.swift
//  leftSwipe
//
//  Created by Fivecode on 22/07/19.
//  Copyright © 2019 Fivecode. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController {
    
    var percentDrivenInteractiveTransition: UIPercentDrivenInteractiveTransition!
    var panGesture: UIPanGestureRecognizer!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        addGesture()
    }
    
    func addGesture() {
        guard (navigationController?.viewControllers.count)! > 1 else { return }

        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture))
    }
    
    @objc func handlePanGesture(gesture: UIPanGestureRecognizer){
        let percent = max(panGesture.translation(in: view).x, 0)
        
        switch gesture.state {
        case .began:
            navigationController?.delegate = self
            navigationController?.popViewController(animated: true)
        case.changed:
            if let percentDrivenInteractiveTransition = percentDrivenInteractiveTransition {
                percentDrivenInteractiveTransition.update(percent)
            }
        case.ended:
            let velocity = panGesture.velocity(in: view).x
            if percent > 0.5 || velocity > 1000 {
                percentDrivenInteractiveTransition.finish()
            }else{
                percentDrivenInteractiveTransition.cancel()
            }
        case.cancelled,.failed:
            percentDrivenInteractiveTransition.cancel()
        default:
            break
        }
    }
}

extension SecondViewController: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        let fromView = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!.view
        let toView = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!.view
        
        let width = containerView.frame.width
        
        var offsetLeft = fromView?.frame
        offsetLeft?.origin.x = width
        
        var offscreenRight = toView?.frame
        offscreenRight?.origin.x = -width / 3.33;
        
        toView?.frame = offscreenRight!;
        
        fromView?.layer.shadowRadius = 5.0
        fromView?.layer.shadowOpacity = 1.0
        toView?.layer.opacity = 0.9
        
        containerView.insertSubview(toView!, belowSubview: fromView!)
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), delay:0, options:.curveLinear, animations:{
            
            toView?.frame = (fromView?.frame)!
            fromView?.frame = offsetLeft!
            
            toView?.layer.opacity = 1.0
            fromView?.layer.shadowOpacity = 0.1
            
        }, completion: { finished in
            toView?.layer.opacity = 1.0
            toView?.layer.shadowOpacity = 0
            fromView?.layer.opacity = 1.0
            fromView?.layer.shadowOpacity = 0
            
            // when cancelling or completing the animation, ios simulator seems to sometimes flash black backgrounds during the animation. on devices, this doesn't seem to happen though.
            // containerView.backgroundColor = [UIColor whiteColor];
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
    
    
}

extension SecondViewController: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        
        navigationController.delegate = nil
        
        if panGesture.state == .began {
            percentDrivenInteractiveTransition = UIPercentDrivenInteractiveTransition()
            percentDrivenInteractiveTransition.completionCurve = .easeOut
        }else{
            percentDrivenInteractiveTransition = nil
        }
        return percentDrivenInteractiveTransition
    }
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
}
