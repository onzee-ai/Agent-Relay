/**
 * SimpleSceneCreator
 * 简化的场景创建器 - 用于自动创建基础 Cocos 场景
 *
 * 使用方式:
 * 1. 复制此文件到你的 Cocos 项目 assets/Script/ 目录
 * 2. 在 Cocos Editor 中创建一个新场景
 * 3. 创建一个空节点，挂载此脚本
 * 4. 设置配置并运行
 */

import { _decorator, Component, Node, Vec3, Color, director, game } from 'cc';

const { ccclass, property } = _decorator;

@ccclass('SimpleSceneCreator')
export class SimpleSceneCreator extends Component {

    // 地面配置
    @property({ displayName: '地面尺寸X' })
    groundSizeX: number = 20;

    @property({ displayName: '地面尺寸Y' })
    groundSizeY: number = 0.1;

    @property({ displayName: '地面尺寸Z' })
    groundSizeZ: number = 20;

    @property({ displayName: '地面颜色R' })
    groundColorR: number = 0.5;

    @property({ displayName: '地面颜色G' })
    groundColorG: number = 0.5;

    @property({ displayName: '地面颜色B' })
    groundColorB: number = 0.5;

    // 摄像机配置
    @property({ displayName: '摄像机X' })
    cameraPosX: number = 0;

    @property({ displayName: '摄像机Y' })
    cameraPosY: number = 10;

    @property({ displayName: '摄像机Z' })
    cameraPosZ: number = 15;

    @property({ displayName: '摄像机看向X' })
    cameraLookX: number = 0;

    @property({ displayName: '摄像机看向Y' })
    cameraLookY: number = 0;

    @property({ displayName: '摄像机看向Z' })
    cameraLookZ: number = 0;

    // 灯光配置
    @property({ displayName: '灯光强度' })
    lightIntensity: number = 1.0;

    @property({ displayName: '灯光颜色R' })
    lightColorR: number = 1.0;

    @property({ displayName: '灯光颜色G' })
    lightColorG: number = 1.0;

    @property({ displayName: '灯光颜色B' })
    lightColorB: number = 1.0;

    // 自动运行
    @property({ displayName: '启动时自动创建' })
    autoCreate: boolean = true;

    start() {
        if (this.autoCreate) {
            this.createSimpleScene();
        }
    }

    /**
     * 创建简单场景
     */
    createSimpleScene() {
        console.log('[SimpleSceneCreator] 开始创建场景...');

        try {
            // 1. 创建地面
            this.createGround();
            console.log('[SimpleSceneCreator] ✓ 地面创建完成');

            // 2. 创建摄像机
            this.createCamera();
            console.log('[SimpleSceneCreator] ✓ 摄像机创建完成');

            // 3. 创建灯光
            this.createLight();
            console.log('[SimpleSceneCreator] ✓ 灯光创建完成');

            console.log('[SimpleSceneCreator] ✓ 场景创建成功！');

        } catch (error) {
            console.error('[SimpleSceneCreator] ✗ 场景创建失败:', error);
        }
    }

    /**
     * 创建地面
     */
    createGround() {
        const ground = new Node('Ground');

        // 设置位置
        ground.setPosition(0, 0, 0);

        // 设置缩放
        ground.setScale(this.groundSizeX, this.groundSizeY, this.groundSizeZ);

        // 添加 MeshRenderer 组件
        const { MeshRenderer, primitive } = require('cc');

        try {
            // 尝试使用 primitive 创建简单几何体
            const mesh = primitive.createMesh('box', {
                width: this.groundSizeX,
                height: this.groundSizeY,
                length: this.groundSizeZ
            });

            const meshRenderer = ground.addComponent(MeshRenderer);
            if (meshRenderer && mesh) {
                meshRenderer.mesh = mesh;

                // 创建材质
                const { Material } = require('cc');
                const material = new Material();
                material.initialize({
                    shader: 'standard'
                });
                material.setProperty('albedo', new Color(
                    this.groundColorR * 255,
                    this.groundColorG * 255,
                    this.groundColorB * 255,
                    255
                ));
                meshRenderer.material = material;
            }
        } catch (e) {
            console.warn('[SimpleSceneCreator] MeshRenderer 创建失败，使用备用方法:', e);
        }

        this.node.addChild(ground);
    }

    /**
     * 创建摄像机
     */
    createCamera() {
        const camera = new Node('Camera');

        // 设置位置
        camera.setPosition(
            this.cameraPosX,
            this.cameraPosY,
            this.cameraPosZ
        );

        // 看向目标点
        camera.lookAt(new Vec3(
            this.cameraLookX,
            this.cameraLookY,
            this.cameraLookZ
        ));

        // 添加 Camera 组件
        const { Camera, CameraProjection, CameraAperture } = require('cc');

        try {
            const cameraComp = camera.addComponent(Camera);
            if (cameraComp) {
                cameraComp.projection = CameraProjection.PERSPECTIVE;
                cameraComp.fov = 45;
                cameraComp.fovAxis = 0;
                cameraComp.near = 0.1;
                cameraComp.far = 1000;
                cameraComp.priority = 0;
                cameraComp.clearFlags = Camera.ClearFlags.DEPTH_AND_COLOR;
                cameraComp.backgroundColor = new Color(135, 206, 235, 255); // 天空蓝
            }
        } catch (e) {
            console.warn('[SimpleSceneCreator] Camera 创建失败:', e);
        }

        this.node.addChild(camera);
    }

    /**
     * 创建灯光
     */
    createLight() {
        const light = new Node('DirectionalLight');

        // 设置旋转（模拟太阳光）
        light.setEulerAngles(45, 45, 0);

        // 添加灯光组件
        const { DirectionalLight, LightType } = require('cc');

        try {
            const lightComp = light.addComponent(DirectionalLight);
            if (lightComp) {
                lightComp.lightType = LightType.DIRECTIONAL;
                lightComp.color = new Color(
                    this.lightColorR * 255,
                    this.lightColorG * 255,
                    this.lightColorB * 255,
                    255
                );
                lightComp.intensity = this.lightIntensity;
                lightComp.illuminance = 10000;
                lightComp.shadowEnabled = true;
            }
        } catch (e) {
            console.warn('[SimpleSceneCreator] Light 创建失败:', e);
        }

        this.node.addChild(light);
    }
}
